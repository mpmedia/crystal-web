if (!Crystal) { var Crystal = {} } if (!Crystal.Field) { Crystal.Field = {} } if (!Crystal.Form) { Crystal.Form = {} }

Crystal.Form.EditUser = {
  method: 'post',
  fields: {
    username: {
      label: 'Username',
      type: 'text'
    },
    company: {
      label: 'Company',
      type: 'text'
    },
    location: {
      label: 'Location',
      type: 'text'
    },
    firstName: {
      label: 'First Name',
      type: 'text'
    },
    lastName: {
      label: 'Last Name',
      type: 'text'
    }
  },
  buttons: {
    submit: {
      label: 'Edit User',
      type: 'submit'
    }
  }
};

if (typeof(module) != 'undefined') module.exports = Crystal.Form.EditUser;