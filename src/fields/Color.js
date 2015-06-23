if (!Crystal) { var Crystal = {} } if (!Crystal.Field) { Crystal.Field = {} }

Crystal.Field.Color = {
  label: 'Color',
  maxLength: 6,
  regex: /[0-9a-f]+/i,
  type: 'text'
};

if (typeof(module) != 'undefined') module.exports = Crystal.Field.Color;