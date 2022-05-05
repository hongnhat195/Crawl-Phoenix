import React from "react";
import { Link } from "react-router-dom";
export default function Action() {
  return (
    <div className="container w-100">
      <h1>
        Click{" "}
        <a
          rel="noreferrer"
          href="http://localhost:4000/download"
          target="_blank">
          here
        </a>{" "}
        to download this data
      </h1>
      <br />
      <br />
      <h1>
        Click <Link to="/show">here</Link> to show data
      </h1>
    </div>
  );
}
