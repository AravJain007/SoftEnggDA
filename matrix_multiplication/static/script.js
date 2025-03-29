document.addEventListener("DOMContentLoaded", function () {
  const matrixSizeInput = document.getElementById("matrix-size");
  const matrixSizeValue = document.getElementById("matrix-size-value");
  const iterationsInput = document.getElementById("iterations");
  const iterationsValue = document.getElementById("iterations-value");
  const runButton = document.getElementById("run-button");
  const progressContainer = document.getElementById("progress-container");
  const progressBarFill = document.getElementById("progress-bar-fill");
  const results = document.getElementById("results");
  const resultsContent = document.getElementById("results-content");

  // Set initial values for the display spans
  matrixSizeValue.textContent = matrixSizeInput.value;
  iterationsValue.textContent = iterationsInput.value;

  // Update displayed values when sliders change
  matrixSizeInput.addEventListener("input", function () {
    matrixSizeValue.textContent = this.value;
  });

  iterationsInput.addEventListener("input", function () {
    iterationsValue.textContent = this.value;
  });

  // Handle run button click
  runButton.addEventListener("click", function () {
    // Get values
    const matrixSize = parseInt(matrixSizeInput.value);
    const iterations = parseInt(iterationsInput.value);

    // Show progress container
    progressContainer.classList.remove("hidden");
    results.classList.add("hidden");
    runButton.disabled = true;

    // Fake progress update (since we don't have real-time updates from the backend)
    let progress = 0;
    const progressInterval = setInterval(() => {
      progress += 5;
      if (progress > 95) clearInterval(progressInterval);
      progressBarFill.style.width = `${progress}%`;
    }, 300);

    // Send the matrix multiplication request
    fetch("/api/matrix-multiply", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        matrix_size: matrixSize,
        iterations: iterations,
      }),
    })
      .then((response) => response.json())
      .then((data) => {
        // Clear any existing results
        resultsContent.innerHTML = "";

        // Add results to the results div
        const resultList = document.createElement("ul");
        data.results.forEach((result) => {
          const item = document.createElement("li");
          item.textContent = `Iteration ${
            result.iteration
          }: ${result.time.toFixed(2)} seconds`;
          resultList.appendChild(item);
        });
        resultsContent.appendChild(resultList);

        // Show results, hide progress
        clearInterval(progressInterval);
        progressBarFill.style.width = "100%";
        setTimeout(() => {
          progressContainer.classList.add("hidden");
          results.classList.remove("hidden");
          runButton.disabled = false;
        }, 500);
      })
      .catch((error) => {
        console.error("Error:", error);
        resultsContent.innerHTML =
          '<p class="error">Error running matrix multiplication. Please try again.</p>';

        // Show results, hide progress
        clearInterval(progressInterval);
        progressContainer.classList.add("hidden");
        results.classList.remove("hidden");
        runButton.disabled = false;
      });
  });
});
