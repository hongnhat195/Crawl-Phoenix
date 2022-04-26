import React from "react";
import { Link } from "react-router-dom";
export default function Action() {
  return (
    <div className="container w-100">
      <h3>
        Click{" "}
        <a href="http://localhost:4000/download" target="_blank">
          here
        </a>{" "}
        to download this data
      </h3>
      <br />
      <br />
      <h3>
        Click <Link to="/show">here</Link> to show data
      </h3>
    </div>
  );
}
