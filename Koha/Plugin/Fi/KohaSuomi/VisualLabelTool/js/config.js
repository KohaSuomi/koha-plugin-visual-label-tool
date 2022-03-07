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
    savedLabels: [],
    label: null,
    updateButton: false,
  },
  created() {
    this.fetchLabels();
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
      this.updateButton = true;
      this.selectedField = undefined;
    },
    updateDimension(e) {
      this.label.fields.forEach((element) => {
        if (element.name == this.selectedField.name) {
          element = this.selectedField;
        }
      });
    },
    createLabel(type) {
      this.label = null;
      this.updateButton = false;
      const object = Object.create({});
      object.name = '';
      object.dimensions = {
        paddingTop: '5mm',
        paddingBottom: '5mm',
        paddingLeft: '5mm',
        paddingRight: '5mm',
        width: '100mm',
        height: '50mm',
      };
      object.fields = [];
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
      this.selectedField = undefined;
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
      this.selectedField = undefined;
      this.showTab = val;
    },
    fetchLabels() {
      axios
        .get('/api/v1/contrib/kohasuomi/labels')
        .then((response) => {
          this.savedLabels = response.data;
        })
        .catch((error) => {
          console.log(error.response.data.message);
        });
    },
    saveLabel(e) {
      e.preventDefault();
      axios
        .post('/api/v1/contrib/kohasuomi/labels', this.label)
        .then((response) => {
          console.log(response);
        })
        .catch((error) => {
          console.log(error.response.data.message);
        });
    },
    updateLabel(e) {
      e.preventDefault();
      axios
        .put('/api/v1/contrib/kohasuomi/labels/' + this.label.id, this.label)
        .then((response) => {
          console.log(response);
        })
        .catch((error) => {
          console.log(error.response.data.message);
        });
    },
    testPrint(e) {
      e.preventDefault();
    },
  },
});
