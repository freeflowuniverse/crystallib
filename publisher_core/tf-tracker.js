const tfTracker = (function () {
    const params = new URLSearchParams(location.search);
    const id = params.get("id");
  
    function sendRequest(state) {
      fetch("/tracker", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(getData(state)),
      })
        .then((res) => res.json())
        .catch(console.log);
    }
  
    function getData(state) {
      return {
        id,
        state,
        url: location.href,
        hash: location.hash.replace("#", ""),
      };
    }
  
    return (hooks) => {
      if (id) {
        hooks.ready(() => {
          sendRequest("open");
  
          window.addEventListener("click", (e) => {
            if (!(e.target instanceof HTMLAnchorElement)) return;
            requestAnimationFrame(() => {
              sendRequest("move");
            });
          });
  
          window.addEventListener("beforeunload", function () {
            sendRequest("close");
            return false;
          });
        });
      }
    };
  })();