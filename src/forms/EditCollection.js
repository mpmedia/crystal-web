if (!Crystal) { var Crystal = {} } if (!Crystal.Field) { Crystal.Field = {} } if (!Crystal.Form) { Crystal.Form = {} }

if (typeof(require) != 'undefined') {
  Crystal.Field.Color = require('../fields/Color');
}

Crystal.Form.EditCollection = {
  action: '/collections/edit',
  method: 'post',
  fields: {
    id: {
      label: 'ID',
      required: true,
      type: 'hidden'
    },
    name: {
      label: 'Name',
      type: 'text'
    },
    color: Crystal.Field.Color
  },
  buttons: {
    submit: {
      label: 'Edit Collection',
      type: 'submit'
    }
  }
};

if (typeof(module) != 'undefined') module.exports = Crystal.Form.EditCollection;