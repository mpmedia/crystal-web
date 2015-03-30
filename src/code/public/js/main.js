$.ajax({
  method: 'POST',
  url: 'http://127.0.0.1:8080/signup',
  data: {
    username: 'username',
    password: 'password'
  },
  success: function(data) {
    console.log(data);
  }
});