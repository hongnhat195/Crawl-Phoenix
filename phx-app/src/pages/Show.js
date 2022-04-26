import axios from "axios";
import React, { useEffect, useState } from "react";

export default function Show() {
  const [list_films, setList_films] = useState([]);
  const [pagination, setPagination] = useState(1);
  const [max_pages, setMaxx] = useState(0);
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

  const showFilms = (list_films) => {
    return list_films.map((film) => {
      return (
        <div className="grid-item">
          <div className="item">
            <div href={film[2]} target="_blank" className="block-wrapper">
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
    showLeftButton(pagination);
    showRightButton(pagination);
  }, [pagination]);
  useEffect(() => {
    fetchData();
  }, []);

  return (
    <div>
      <div class="container-fluid show">
        <div class="d-flex flex-row justify-content-around pt-5">
          <div class="left ">
            {showLeftButton(pagination)}
            <button class="btn btn-success"> {pagination} </button>
            {showRightButton(pagination)}
            <div></div>
          </div>
        </div>
        <div className="grid-container container-fluid ">
          {showFilms(list_films)}
        </div>
      </div>
    </div>
  );
}
