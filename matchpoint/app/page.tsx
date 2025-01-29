import Button from "@/components/button";
import Layout from "@/components/layout";

export default function Homepage() {
  return (
    <Layout>
      <div className="min-h-screen bg-white text-darkBlue flex flex-col items-center">
        {/* Hero Section */}
        <section className="w-full text-center py-20 px-6 bg-darkBlue text-white relative">
          <h1 className="text-4xl md:text-6xl font-bold text-orange-500">Rank <span className="text-white">UP</span> in Real Life...</h1>
          <p className="mt-4 text-lg md:text-xl">HYPE VIDEO ON REPEAT*</p>
        </section>

        {/* Challenge Section */}
        <section className="w-full text-center py-20 px-6 bg-gradient-to-b from-darkBlue to-black text-white">
          <h2 className="text-3xl md:text-5xl font-bold">Challenge Your Opponents Now</h2>
          <p className="mt-4 text-lg">Make friends, join communities & more</p>
        </section>

        {/* Sports Section */}
        <section className="w-full max-w-5xl py-20 px-6 text-center">
          <h3 className="text-2xl font-semibold text-orange-500">A Range of Sports Just for You!</h3>
          <p className="mt-2 text-lg">Put on easy access into a plethora of available sports.</p>
        </section>

        {/* Call to Action Section */}
        <section className="w-full text-center py-20 px-6 bg-orange-500 text-white flex flex-col items-center">
          <h2 className="text-3xl md:text-4xl font-bold">Sign Up Now to Gain Access</h2>
          <ul className="mt-4 text-lg text-left">
            <li>- Play with actual skill levels</li>
            <li>- Active Communities</li>
            <li>- Local & International Leader Boards</li>
            <li>- Logistic Transparent Levels</li>
          </ul>
          <Button className="mt-6 bg-white text-orange-500 hover:bg-gray-200 px-6 py-3 rounded-lg">
            Sign Up Now
          </Button>
        </section>

        {/* Footer */}
        <footer className="w-full bg-darkBlue text-white py-6 text-center">
          <p>Contact Us Today</p>
          <p>@matchpointarena | matchpointsupport@xyz.org</p>
        </footer>
      </div>
    </Layout>
  );
}