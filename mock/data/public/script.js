const form = document.querySelector("#submit-form")
form.addEventListener("submit", async (event) => {
  event.preventDefault()
  const obj = {}
  for (const item of event.target.elements) {
    if (item.name.length !== 0) {
      obj[item.name] = item.value
    }
  }
  const response = await axios.post("/payload/submit", obj)
})
