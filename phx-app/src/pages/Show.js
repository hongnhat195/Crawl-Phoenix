import axios from "axios";
import React, { useEffect, useState } from "react";

export default function Show() {
  const [list_films, setList_films] = useState([]);
  const [pagination, setPagination] = useState(1);
  const [max_pages, setMaxx] = useState(0);
  const [list_country, setList_country] = useState([]);
  const [country, setCountry] = useState("");
  const [actor, setActor] = useState("");
  const fetchData = async () => {
    const res = await axios.get("http://localhost:4000/api/show");
    setList_films(res.data.list_films);
    setPagination(res.data.pagination);
    setMaxx(res.data.max_pages);
  };

  const fetchPagiData = async (pagination) => {
    const res = await axios.get(
      `http://localhost:4000/api/pagi?pagination=${pagination}&country=${country}&actor=${actor}`
    );
    console.log(res.data);
    setList_films(res.data.list_films);
    setPagination(res.data.pagination);
  };

  const fetchCountry = async () => {
    const res = await axios.get("http://localhost:4000/api/country");
    setList_country(res.data.list_country);
  };

  const showDropdownCountry = (list_country) => {
    return list_country.map((country, idx) => {
      return (
        <li key={idx}>
          <div onClick={() => setCountry(country)} className="dropdown-item">
            {country}
          </div>
        </li>
      );
    });
  };

  const showFilms = (list_films) => {
    return list_films.map((film, idx) => {
      return (
        <div key={idx} className="grid-item">
          <div className="item">
            <div className="block-wrapper">
              <img className="w-100" src={film[3]} alt={film[3]} />
              <div className="more">
                <p> Năm sản xuất: {film[5]} </p>
                <p> Số tập đã phát: {film[4]} </p>
                <p>
                  Full Series:{" "}
                  {film[6] === false ? "Chưa full" : "Đã hoàn thành"}
                </p>
                <p> Đạo diễn: {film[8]} </p>
              </div>
            </div>
            <div className="film-meta">
              <p>
                {" "}
                <a
                  rel="noreferrer"
                  alt={film[2]}
                  href={film[2]}
                  target="_blank">
                  {" "}
                  {film[1]} - {film[5]}{" "}
                </a>{" "}
              </p>
            </div>
          </div>
        </div>
      );
    });
  };

  const showLeftButton = (pagination) => {
    if (pagination > 1) {
      return (
        <>
          <button onClick={() => setPagination(1)} class="btn btn-light">
            Fisrt
          </button>

          <button
            onClick={() => setPagination(pagination - 1)}
            className="btn btn-light">
            Prev
          </button>

          <button
            onClick={() => setPagination(pagination - 1)}
            className="btn btn-light">
            {" "}
            {pagination - 1}{" "}
          </button>
        </>
      );
    }
  };

  const showRightButton = (pagination) => {
    if (pagination < max_pages)
      return (
        <>
          <button
            onClick={() => setPagination(pagination + 1)}
            className="btn btn-light">
            {" "}
            {pagination + 1}
          </button>

          <button
            onClick={() => setPagination(pagination + 1)}
            className="btn btn-light">
            Next
          </button>
          <button
            onClick={() => setPagination(max_pages)}
            className="btn btn-light">
            Last
          </button>
        </>
      );
  };

  useEffect(() => {
    fetchPagiData(pagination);
  }, [pagination, country, actor]);

  useEffect(() => {
    fetchData();
    fetchCountry();
  }, []);

  return (
    <div>
      <div className="container-fluid show">
        <div className="header d-flex flex-row justify-content-around  pt-5">
          <div className="left  btn-group d-flex flex-row flex-wrap align-middle">
            {showLeftButton(pagination)}
            <button
              onClick={() => setPagination(pagination)}
              className="btn btn-success">
              {" "}
              {pagination}{" "}
            </button>
            {showRightButton(pagination)}
            <div></div>
          </div>
          <div className="right d-flex flex-row  justify-content-around align-middle ">
            <input
              onChange={(e) => setActor(e.target.value)}
              type="text"
              placeholder="Filter by actor"
              className=" me-5 pe-5  form-control-lg"
            />

            <div className="dropdown">
              <button
                className="btn btn-secondary p-5 dropdown-toggle text-center "
                type="button"
                id="dropdownMenuButton1"
                data-bs-toggle="dropdown"
                aria-expanded="false">
                {country === "" ? "Chọn Quốc Gia" : country}
              </button>
              <ul
                className="dropdown-menu"
                aria-labelledby="dropdownMenuButton1">
                <li>
                  <div
                    onClick={() => {
                      setCountry("");
                    }}
                    className="dropdown-item">
                    Tất cả quốc gia
                  </div>
                </li>
                {showDropdownCountry(list_country)}
              </ul>
            </div>
          </div>
        </div>
        <div className="grid-container container-fluid ">
          {showFilms(list_films)}
        </div>
      </div>
    </div>
  );
}
