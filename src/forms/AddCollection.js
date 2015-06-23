if (!Crystal) { var Crystal = {} } if (!Crystal.Field) { Crystal.Field = {} } if (!Crystal.Form) { Crystal.Form = {} }

if (typeof(require) != 'undefined') {
  Crystal.Field.Color = require('../fields/Color');
}

Crystal.Form.AddCollection = {
  action: '/collections',
  method: 'post',
  fields: {
    name: {
      label: 'Name',
      type: 'text'
    },
    color: Crystal.Field.Color
  },
  buttons: {
    submit: {
      label: 'Add Collection',
      type: 'submit'
    }
  }
};

if (typeof(module) != 'undefined') module.exports = Crystal.Form.AddCollection;