import axios from "axios";
import React, { useEffect, useState } from "react";

export default function Show() {
  const [list_films, setList_films] = useState([]);
  const [pagination, setPagination] = useState(1);
  const [max_pages, setMaxx] = useState(0);
  const [list_country, setList_country] = useState([]);
  const [country, setCountry] = useState("");
  const fetchData = async () => {
    const res = await axios.get("http://localhost:4000/api/show");
    setList_films(res.data.list_films);
    setPagination(res.data.pagination);
    setMaxx(res.data.max_pages);
  };

  const fetchPagiData = async (pagination) => {
    const res = await axios.get(
      `http://localhost:4000/api/pagi?pagination=${pagination}`
    );
    setList_films(res.data.list_films);
    setPagination(res.data.pagination);
  };
  const showDropdownActor = (list_country) => {
    return list_country.map((country) => {
      return (
        <li>
          <div
            onClick={() => setCountry(country)}
            value={country}
            className="dropdown-item">
            {country}
          </div>
        </li>
      );
    });
  };
  const filter_by_country = async (page, country) => {
    const res = await axios.get(
      `http://localhost:4000/api/show_filter?pagination=${page}&country=${country}`
    );
    setList_films(res.data.list_films);
  };
  const fetchActor = async () => {
    const res = await axios.get("http://localhost:4000/api/country");
    setList_country(res.data.list_country);
  };

  const showFilms = (list_films) => {
    return list_films.map((film) => {
      return (
        <div className="grid-item">
          <div className="item">
            <div className="block-wrapper">
              <img className="w-100" src={film[3]} alt={film[3]} />
              <div className="more">
                <p> Năm sản xuất: {film[5]} </p>
                <p> Số tập đã phát: {film[4]} </p>
                <p> Full Series: {film[6]} </p>
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
        <div className="btn-group">
          <button onClick={() => setPagination(1)} class="btn btn-light">
            Fisrt
          </button>

          <button
            onClick={() => setPagination(pagination - 1)}
            class="btn btn-light">
            Prev
          </button>

          <button
            onClick={() => setPagination(pagination - 1)}
            class="btn btn-light">
            {" "}
            {pagination - 1}{" "}
          </button>
        </div>
      );
    }
  };

  const showRightButton = (pagination) => {
    if (pagination < max_pages)
      return (
        <div className="btn-group">
          <button
            onClick={() => setPagination(pagination + 1)}
            class="btn btn-light">
            {" "}
            {pagination + 1}
          </button>

          <button
            onClick={() => setPagination(pagination + 1)}
            class="btn btn-light">
            Next
          </button>
          <button
            onClick={() => setPagination(max_pages)}
            class="btn btn-light">
            Last
          </button>
        </div>
      );
  };

  useEffect(() => {
    fetchPagiData(pagination);
  }, [pagination]);

  useEffect(() => {
    fetchData();
    fetchActor();
  }, []);

  useEffect(() => {
    filter_by_country(pagination, country);
    console.log(pagination, country);
  }, [country, pagination]);

  return (
    <div>
      <div class="container-fluid show">
        <div class=" header d-flex flex-row justify-content-around pt-5">
          <div class="left btn-group">
            {showLeftButton(pagination)}
            <button className="btn btn-success"> {pagination} </button>
            {showRightButton(pagination)}
            <div></div>
          </div>
          <div className="right d-flex flex-row  justify-content-around ">
            <input
              type="text"
              placeholder="Filter by actor"
              className="w-100  me-3 form-control form-control-lg"
            />

            <div className="dropdown">
              <button
                className="btn btn-secondary mb-5 dropdown-toggle "
                type="button"
                id="dropdownMenuButton1"
                data-bs-toggle="dropdown"
                aria-expanded="false">
                {country === "" ? "Chọn Quốc Gia" : country}
              </button>
              <ul
                className="dropdown-menu"
                aria-labelledby="dropdownMenuButton1">
                {showDropdownActor(list_country)}
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
