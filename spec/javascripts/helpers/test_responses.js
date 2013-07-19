var TestResponses = {
  registration: {
    success: {
      status: 200,
      responseText: '{"foo":"bar"}'
    },

    failure: {
      status: 403,
      responseText: "{\"error_message\":\"Please Correct the below errors:\",\"errors\":{\"first_name\":[\"Please enter a First Name\"],\"password\":[\"Please enter a password at least 6 characters long\"]}}"
    }
  }
}