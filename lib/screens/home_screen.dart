import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../config/supabase_config.dart';
import '../theme/app_theme.dart';
import '../models/player.dart';
import '../models/play_zone.dart';
import '../models/court.dart';
import '../data/mock_data.dart';
import '../utils/sport_utils.dart';
import '../widgets/player_card.dart';
import '../widgets/player_detail_sheet.dart';
import '../widgets/court_detail_sheet.dart';
import '../widgets/filter_modal.dart';

/// Home Screen — Map-based player discovery with zone markers,
/// player drawers, challenge flow, and court selection.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ──── State ────
  GoogleMapController? _mapController;
  PlayZone? _selectedZone;
  Player? _selectedPlayer;
  Court? _selectedCourt;
  bool _isCourtMode = false;
  Player? _challengeTarget;
  Set<String> _sportFilters = {};
  bool _availableNowOnly = false;

  // ──── Animation Controllers ────
  late AnimationController _zoneDrawerController;
  late AnimationController _playerDetailController;
  late AnimationController _courtDetailController;
  late Animation<Offset> _zoneDrawerSlide;
  late Animation<Offset> _playerDetailSlide;
  late Animation<Offset> _courtDetailSlide;

  @override
  void initState() {
    super.initState();
    _zoneDrawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _playerDetailController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _courtDetailController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _zoneDrawerSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _zoneDrawerController,
      curve: Curves.easeOutCubic,
    ));
    _playerDetailSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _playerDetailController,
      curve: Curves.easeOutCubic,
    ));
    _courtDetailSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _courtDetailController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _zoneDrawerController.dispose();
    _playerDetailController.dispose();
    _courtDetailController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // ──── Filtered Data ────
  List<PlayZone> get _filteredZones {
    return MockData.playZones.map((zone) {
      final filtered = zone.players.where((p) {
        if (_sportFilters.isNotEmpty &&
            !p.sports.any((s) => _sportFilters.contains(s))) {
          return false;
        }
        if (_availableNowOnly && !p.availableNow) return false;
        return true;
      }).toList();
      return zone.copyWith(players: filtered);
    }).where((z) => z.players.isNotEmpty).toList();
  }

  List<Court> get _filteredCourts {
    if (_challengeTarget == null) return MockData.courts;
    return MockData.courts.where((c) {
      return c.sports.any((s) => _challengeTarget!.sports.contains(s));
    }).toList();
  }

  // ──── Actions ────
  void _onZoneTapped(PlayZone zone) {
    _closeAllDrawers();
    setState(() => _selectedZone = zone);
    _zoneDrawerController.forward();

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(zone.latitude, zone.longitude),
        14,
      ),
    );
  }

  void _onPlayerTapped(Player player) {
    _zoneDrawerController.reverse();
    setState(() => _selectedPlayer = player);
    _playerDetailController.forward();
  }

  void _onChallenge(Player player) {
    _playerDetailController.reverse();
    setState(() {
      _challengeTarget = player;
      _isCourtMode = true;
      _selectedPlayer = null;
    });
  }

  void _onCourtTapped(Court court) {
    _closeAllDrawers();
    setState(() => _selectedCourt = court);
    _courtDetailController.forward();

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(court.latitude, court.longitude),
        15,
      ),
    );
  }

  void _onCourtSelected(Court court) {
    _courtDetailController.reverse();
    setState(() {
      _isCourtMode = false;
      _challengeTarget = null;
      _selectedCourt = null;
    });
    // Navigate to matches tab (index 1) via callback — for now show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Match challenge sent! Court: ${court.name}',
          style: AppTheme.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _cancelCourtMode() {
    _closeAllDrawers();
    setState(() {
      _isCourtMode = false;
      _challengeTarget = null;
      _selectedCourt = null;
    });
  }

  void _closeAllDrawers() {
    _zoneDrawerController.reverse();
    _playerDetailController.reverse();
    _courtDetailController.reverse();
    setState(() {
      _selectedZone = null;
      _selectedPlayer = null;
      _selectedCourt = null;
    });
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterModal(
        selectedSports: _sportFilters,
        availableNowOnly: _availableNowOnly,
        onSportsChanged: (sports) => setState(() => _sportFilters = sports),
        onAvailableNowChanged: (val) => setState(() => _availableNowOnly = val),
      ),
    );
  }

  // ──── Map Markers ────
  Set<Marker> get _markers {
    if (_isCourtMode) {
      return _filteredCourts.map((court) {
        return Marker(
          markerId: MarkerId('court_${court.id}'),
          position: LatLng(court.latitude, court.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          onTap: () => _onCourtTapped(court),
        );
      }).toSet();
    }

    return _filteredZones.map((zone) {
      return Marker(
        markerId: MarkerId('zone_${zone.id}'),
        position: LatLng(zone.latitude, zone.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          zone.isUserZone ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueOrange,
        ),
        onTap: () => _onZoneTapped(zone),
      );
    }).toSet();
  }

  // ──── Build ────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map or Placeholder
          _buildMap(),

          // Header overlay
          _buildHeader(),

          // Play Zone badge
          if (!_isCourtMode) _buildPlayZoneBadge(),

          // Court mode banner
          if (_isCourtMode) _buildCourtModeBanner(),

          // Zone Drawer (bottom sheet with player grid)
          if (_selectedZone != null)
            SlideTransition(
              position: _zoneDrawerSlide,
              child: _buildZoneDrawer(),
            ),

          // Player Detail Sheet
          if (_selectedPlayer != null)
            SlideTransition(
              position: _playerDetailSlide,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: PlayerDetailSheet(
                  player: _selectedPlayer!,
                  onChallenge: () => _onChallenge(_selectedPlayer!),
                  onClose: () {
                    _playerDetailController.reverse();
                    setState(() => _selectedPlayer = null);
                  },
                ),
              ),
            ),

          // Court Detail Sheet
          if (_selectedCourt != null)
            SlideTransition(
              position: _courtDetailSlide,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: CourtDetailSheet(
                  court: _selectedCourt!,
                  onSelect: () => _onCourtSelected(_selectedCourt!),
                  onClose: () {
                    _courtDetailController.reverse();
                    setState(() => _selectedCourt = null);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (!SupabaseConfig.isMapsConfigured) {
      return _buildMapPlaceholder();
    }

    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(40.7128, -74.0060),
        zoom: 12,
      ),
      markers: _markers,
      onMapCreated: (controller) => _mapController = controller,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
    );
  }

  Widget _buildMapPlaceholder() {
    final zones = _isCourtMode ? <PlayZone>[] : _filteredZones;
    final courts = _isCourtMode ? _filteredCourts : <Court>[];

    return Container(
      color: AppTheme.surfaceLight,
      child: Column(
        children: [
          const SizedBox(height: 140),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Map placeholder icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _isCourtMode ? Icons.sports_tennis : Icons.map_outlined,
                          size: 40,
                          color: _isCourtMode ? AppTheme.successGreen : AppTheme.primaryBlue,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isCourtMode
                              ? 'Select a Court'
                              : 'Map View (Add Google Maps API key)',
                          style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Show zones or courts as tappable cards
                  if (!_isCourtMode)
                    ...zones.map((zone) => _ZoneCard(
                          zone: zone,
                          onTap: () => _onZoneTapped(zone),
                        )),
                  if (_isCourtMode)
                    ...courts.map((court) => _CourtCard(
                          court: court,
                          onTap: () => _onCourtTapped(court),
                        )),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          left: 20,
          right: 20,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          color: AppTheme.background.withOpacity(0.95),
          border: const Border(bottom: BorderSide(color: AppTheme.border, width: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isCourtMode ? 'Select Court' : 'Find Players Nearby',
              style: AppTheme.headingLarge,
            ),
            if (!_isCourtMode)
              GestureDetector(
                onTap: _showFilters,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _sportFilters.isNotEmpty || _availableNowOnly
                        ? AppTheme.primaryBlue.withOpacity(0.1)
                        : AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _sportFilters.isNotEmpty || _availableNowOnly
                          ? AppTheme.primaryBlue
                          : AppTheme.border,
                    ),
                  ),
                  child: Icon(
                    Icons.filter_list,
                    color: _sportFilters.isNotEmpty || _availableNowOnly
                        ? AppTheme.primaryBlue
                        : AppTheme.textSecondary,
                    size: 22,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayZoneBadge() {
    final userZone = MockData.playZones.firstWhere(
      (z) => z.isUserZone,
      orElse: () => MockData.playZones.first,
    );
    return Positioned(
      top: MediaQuery.of(context).padding.top + 64,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Your Play Zone: ${userZone.name}',
                style: AppTheme.labelMedium.copyWith(
                  color: Colors.white,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourtModeBanner() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 64,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.successGreen,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.successGreen.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.sports_tennis, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Select court for challenge vs ${_challengeTarget?.username ?? ""}',
                style: AppTheme.labelMedium.copyWith(color: Colors.white, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: _cancelCourtMode,
              child: const Icon(Icons.close, size: 20, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneDrawer() {
    final zone = _selectedZone!;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.45,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderInput,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Zone header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(zone.name, style: AppTheme.headingSmall),
                        const SizedBox(height: 2),
                        Text(
                          '${zone.players.length} player${zone.players.length != 1 ? 's' : ''} nearby',
                          style: AppTheme.caption,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _zoneDrawerController.reverse();
                      setState(() => _selectedZone = null);
                    },
                    child: const Icon(Icons.close, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Player grid
            Flexible(
              child: zone.players.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, size: 40, color: AppTheme.borderInput),
                          const SizedBox(height: 8),
                          Text('No players match your filters',
                              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: zone.players.length,
                      itemBuilder: (_, i) => PlayerCard(
                        player: zone.players[i],
                        onTap: () => _onPlayerTapped(zone.players[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──── Fallback Cards (shown when no Google Maps API key) ────

class _ZoneCard extends StatelessWidget {
  final PlayZone zone;
  final VoidCallback onTap;
  const _ZoneCard({required this.zone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: zone.isUserZone ? AppTheme.primaryBlue : AppTheme.border,
            width: zone.isUserZone ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: zone.isUserZone
                    ? AppTheme.primaryBlue.withOpacity(0.1)
                    : AppTheme.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.location_on,
                color: zone.isUserZone ? AppTheme.primaryBlue : AppTheme.primaryOrange,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(zone.name, style: AppTheme.labelMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${zone.players.length} player${zone.players.length != 1 ? 's' : ''}',
                    style: AppTheme.caption,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _CourtCard extends StatelessWidget {
  final Court court;
  final VoidCallback onTap;
  const _CourtCard({required this.court, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.sports_tennis,
                color: AppTheme.successGreen,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(court.name, style: AppTheme.labelMedium),
                  const SizedBox(height: 2),
                  Text(
                    court.sports.map((s) => SportUtils.getEmoji(s)).join(' ') +
                        (court.locationName != null ? '  •  ${court.locationName}' : ''),
                    style: AppTheme.caption,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
