const Multiselect = Vue.component(
  'vue-multiselect',
  window.VueMultiselect.default
);

new Vue({
  el: '#configApp',
  components: {
    Multiselect,
  },
  data: {
    fieldName: '',
    selectedField: null,
    showTab: 'labelSettings',
    totalWidth: '',
    totalHeight: '',
    savedLabels: [
      {
        name: 'Pohja',
        dimensions: {
          paddingTop: '5mm',
          paddingBottom: '5mm',
          paddingLeft: '5mm',
          paddingRight: '5mm',
          width: '100mm',
          height: '50mm',
        },
        fields: [
          {
            name: 'title',
            dimensions: {
              top: '1mm',
              left: '1mm',
              fontSize: '20px',
            },
          },
          {
            name: 'juupas',
            dimensions: {
              top: '5mm',
              left: '1mm',
              fontSize: '20px',
            },
          },
        ],
      },
    ],
    label: null,
    default: {
      name: '',
      dimensions: {
        paddingTop: '5mm',
        paddingBottom: '5mm',
        paddingLeft: '5mm',
        paddingRight: '5mm',
        width: '100mm',
        height: '50mm',
      },
      fields: [],
    },
  },
  methods: {
    onLabelChange() {
      this.totalWidth =
        parseInt(this.label.dimensions.width) +
        parseInt(this.label.dimensions.paddingLeft) +
        parseInt(this.label.dimensions.paddingRight);
      this.totalHeight =
        parseInt(this.label.dimensions.height) +
        parseInt(this.label.dimensions.paddingBottom) +
        parseInt(this.label.dimensions.paddingTop);
    },
    updateDimension(e) {
      this.label.fields.forEach((element) => {
        if (element.name == this.selectedField.name) {
          element = this.selectedField;
        }
      });
    },
    createLabel(type) {
      const object = Object.create(this.default);
      if (type == 'signum') {
        object.signum = {
          dimensions: {
            paddingTop: '5mm',
            paddingBottom: '5mm',
            paddingLeft: '5mm',
            paddingRight: '5mm',
            width: '20mm',
            height: '50mm',
          },
          fields: [],
        };
      }
      this.label = object;
    },
    addField(e, type) {
      e.preventDefault();
      const object = Object.create({});
      object.name = this.fieldName;
      object.dimensions = {
        top: '0mm',
        left: '0mm',
        fontSize: '20px',
      };
      this.selectedField = object;
      if (type == 'signum') {
        this.label.signum.fields.push(this.selectedField);
      } else {
        this.label.fields.push(this.selectedField);
      }
      this.fieldName = '';
    },
    showTabs(val) {
      this.showTab = val;
    },
    saveLabel(e) {
      e.preventDefault();
    },
    testPrint(e) {
      e.preventDefault();
    },
  },
});
