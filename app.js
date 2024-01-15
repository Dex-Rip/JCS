document.addEventListener("DOMContentLoaded", function () {
  // Initialize functionalities on page load
  updateCheckList().catch(showError);
});

document
  .getElementById("issueCheckForm")
  .addEventListener("submit", async function (event) {
    event.preventDefault();
    try {
      const checkData = {
        amount: document.getElementById("amount").value,
        recipients: document.getElementById("recipients").value.split(","),
        contractHash: document.getElementById("contractHash").value,
        expirationDate: document.getElementById("expirationDate").value,
      };

      const response = await fetch("/api/createCheck", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(checkData),
      });

      if (!response.ok) {
        throw new Error("Failed to create check");
      }

      const result = await response.json();
      showMessage(result.message);
      updateCheckList();
    } catch (error) {
      showError(error);
    }
  });

async function updateCheckList() {
  try {
    const response = await fetch("/api/getChecks");
    if (!response.ok) {
      throw new Error("Failed to fetch checks");
    }

    const checks = await response.json();
    const checksList = document.getElementById("checkItems");
    checksList.innerHTML = ""; // Clear existing items

    checks.forEach((check) => {
      const listItem = document.createElement("li");
      listItem.textContent = `Check ID: ${check.id}, Amount: ${check.amount}`;
      // Add more check details as needed
      checksList.appendChild(listItem);
    });
  } catch (error) {
    showError(error);
  }
}

// Additional functions to handle signing, rejecting, etc.
// ...

// Utility function to show error messages
function showError(error) {
  console.error(error);
  alert(error.message); // Replace with a more sophisticated error display
}

// Utility function to show general messages
function showMessage(message) {
  alert(message); // Replace with a better message display mechanism
}
