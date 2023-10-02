const express = require('express')
const app = express()
const port = 3000

app.get('/', (req, res) => {
  console.log("request received")
  res.send('This is My App ! version:v2')
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})