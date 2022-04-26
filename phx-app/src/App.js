import "./App.css";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import Home from "./pages/Home";
import Action from "./pages/Action";
import Show from "./pages/Show";
function App() {
  return (
    <div className="App">
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/action" element={<Action />} />
          <Route path="/show" element={<Show />} />
        </Routes>
      </BrowserRouter>
    </div>
  );
}

export default App;
