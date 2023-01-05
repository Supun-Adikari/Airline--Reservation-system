const express = require('express')
const app = express()
app.set('view engine', 'ejs')


app.get('/home',(req,res)=>{
    res.render('home.ejs')
})

app.get('/login',(req,res)=>{
    res.render('login.ejs')
})

app.get('/feedback',(req,res)=>{
    res.render('feedback.ejs')
})

app.get('/book',(req,res)=>{
    res.render('book.ejs')
})


app.get('/admin',(req,res)=>{
    res.render('admin.ejs')
})

app.get('/adminLogin',(req,res)=>{
    res.render('adminLogin.ejs')
})

app.use(express.static('public'))

const port = 8000
app.listen(port, () => {
  console.log(`Example app listening on port http://localhost:${port}`)
})