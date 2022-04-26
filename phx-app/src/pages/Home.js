import React, { useState } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";
export default function Home() {
  const navigate = useNavigate();
  const [value, setValue] = useState("");
  const handleChange = (e) => {
    e.preventDefault();
    setValue(e.target.value);
  };

  const handleSubmit = async () => {
    const res = await axios.post(`http://localhost:4000/api?url=${value}`);
    if (res.status === 201) navigate("/action");
  };
  return (
    <div className="container w-50" style={{ fontSize: "5rem" }}>
      <div class="mb-3">
        <label class="form-label">Enter the URL:</label>
        <input
          type="text"
          class="form-control"
          value={value}
          onChange={handleChange}
        />
      </div>
      <button className="btn btn-primary" onClick={handleSubmit}>
        Submit
      </button>
    </div>
  );
}
