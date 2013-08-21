var TestResponses = {
  registration: {
    success: {
      status: 200,
      responseText: '{"redirect_path":"/foonazzle"}'
    },

    failure: {
      status: 403,
      responseText: "{\"error_message\":\"Please correct the errors below:\",\"errors\":{\"first_name\":[\"Please enter a First Name\"],\"password\":[\"Please enter a password at least 6 characters long\"]}}"
    }
  }
}