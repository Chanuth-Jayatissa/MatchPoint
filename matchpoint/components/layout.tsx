"use client";

import { useState } from "react";
import { Menu, X } from "lucide-react";
import Button from "@/components/button";

interface LayoutProps {
  children: React.ReactNode;
}

export default function Layout({ children }: LayoutProps) {
  const [menuOpen, setMenuOpen] = useState(false);

  return (
    <div className="min-h-screen bg-white text-darkBlue flex flex-col items-center">
      {/* Navbar */}
      <nav className="bg-blue-600 text-white p-4 flex justify-between items-center shadow-md w-full max-w-5xl rounded-full mt-4 px-6">
        <h1 className="text-2xl font-bold text-black bg-white px-3 py-1 rounded-lg">MatchPoint</h1>
        <div className="hidden md:flex space-x-6">
          <a href="#" className="hover:text-orange-400">Home</a>
          <a href="#" className="hover:text-orange-400">Explore</a>
          <a href="#" className="hover:text-orange-400">Shop</a>
          <a href="#" className="hover:text-orange-400">Community</a>
          <a href="#" className="text-orange-500 font-semibold">Donate</a>
        </div>
        <div className="md:flex items-center space-x-3 hidden">
          <a href="#" className="text-gray-300 hover:text-white">Sign out</a>
          <div className="w-8 h-8 bg-gray-700 rounded-full flex items-center justify-center">
            <span className="text-white">🧑</span>
          </div>
        </div>
        <div className="md:hidden">
          <Button variant="ghost" onClick={() => setMenuOpen(!menuOpen)}>
            {menuOpen ? <X size={24} /> : <Menu size={24} />}
          </Button>
        </div>
      </nav>
      
      {/* Mobile Menu */}
      {menuOpen && (
        <div className="md:hidden bg-blue-600 text-white p-4 flex flex-col space-y-4 w-full rounded-lg mt-2">
          <a href="#" className="hover:text-orange-400">Home</a>
          <a href="#" className="hover:text-orange-400">Explore</a>
          <a href="#" className="hover:text-orange-400">Shop</a>
          <a href="#" className="hover:text-orange-400">Community</a>
          <a href="#" className="text-orange-500 font-semibold">Donate</a>
        </div>
      )}
      
      {/* Main Content */}
      <main className="flex-1 p-6 w-full max-w-screen-lg mx-auto">{children}</main>
    </div>
  );
}
