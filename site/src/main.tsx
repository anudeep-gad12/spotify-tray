import ReactDOM from "react-dom/client";
import { CapabilityGrid } from "./components/CapabilityGrid";
import { InstallPreCta } from "./components/InstallPreCta";
import { OpenSourceSection } from "./components/OpenSourceSection";
import { ShortcutsStrip } from "./components/ShortcutsStrip";
import { FinalCta } from "./sections/FinalCta";
import { Footer } from "./sections/Footer";
import { Header } from "./sections/Header";
import { HeroSection } from "./sections/HeroSection";
import "./styles.css";

function App() {
  return (
    <div className="page">
      <Header />
      <main>
        <HeroSection />
        <ShortcutsStrip />
        <OpenSourceSection />
        <InstallPreCta />
        <CapabilityGrid />
        <FinalCta />
      </main>
      <Footer />
    </div>
  );
}

ReactDOM.createRoot(document.getElementById("root")!).render(<App />);
