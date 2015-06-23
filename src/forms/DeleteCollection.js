if (!Crystal) { var Crystal = {} } if (!Crystal.Field) { Crystal.Field = {} } if (!Crystal.Form) { Crystal.Form = {} }

Crystal.Form.DeleteCollection = {
  action: '/collections/delete',
  method: 'post',
  fields: {
    id: {
      label: 'ID',
      required: true,
      type: 'hidden'
    }
  },
  buttons: {
    submit: {
      label: 'Delete Collection',
      type: 'submit'
    }
  }
};

if (typeof(module) != 'undefined') module.exports = Crystal.Form.DeleteCollection;