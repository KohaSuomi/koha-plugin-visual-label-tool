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
    saved: false,
    errors: [],
    labelTypes: [
      { name: 'A4/14', value: '14' },
      { name: 'A4/12', value: '12' },
      { name: 'A4/10', value: '10' },
      { name: 'Rulla', value: 'roll' },
      { name: 'A4/signum', value: 'signum' },
    ],
    showSignum: false,
    selectedType: null,
  },
  created() {
    this.fetchLabels();
  },
  methods: {
    onLabelChange() {
      this.saved = false;
      this.showSignum = false;
      this.selectedType = null;
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
    createLabel() {
      this.showTabs('labelSettings');
      this.label = null;
      this.updateButton = false;
      const object = Object.create({});
      object.name = '';
      object.type = this.selectedType.value;
      if (parseInt(this.selectedType.value)) {
        object.labelcount = this.selectedType.value;
      }
      object.dimensions = {
        paddingTop: '1mm',
        paddingBottom: '1mm',
        paddingLeft: '1mm',
        paddingRight: '1mm',
        width: '90mm',
        height: '40mm',
      };
      object.fields = [];
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
    addSignum(e) {
      e.preventDefault();
      this.showSignum = true;
      const object = Object.create({});
      object.dimensions = {
        paddingTop: '1mm',
        paddingBottom: '1mm',
        paddingLeft: '1mm',
        paddingRight: '1mm',
        width: '20mm',
        height: '20mm',
      };
      object.fields = [];
      this.label.signum = object;
      this.showTabs('signumSettings');
    },
    deleteSignum(e) {
      e.preventDefault();
      delete this.label['signum'];
      this.showSignum = false;
      this.showTabs('labelSettings');
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
          this.errors.push(error.response.data.message);
        });
    },
    saveLabel(e) {
      e.preventDefault();
      this.saved = false;
      axios
        .post('/api/v1/contrib/kohasuomi/labels', this.label)
        .then((response) => {
          this.saved = true;
          this.updateButton = true;
          this.label = response.data;
          this.fetchLabels();
        })
        .catch((error) => {
          this.errors.push(error.response.data.message);
        });
    },
    updateLabel(e) {
      e.preventDefault();
      this.saved = false;
      axios
        .put('/api/v1/contrib/kohasuomi/labels/' + this.label.id, this.label)
        .then(() => {
          this.saved = true;
        })
        .catch((error) => {
          this.errors.push(error.response.data.message);
        });
    },
    deleteLabel(e) {
      e.preventDefault();
      if (confirm('Haluatko varmasti poistaa tarran ' + this.label.name)) {
        axios
          .delete('/api/v1/contrib/kohasuomi/labels/' + this.label.id)
          .then(() => {
            this.label = null;
            this.saved = false;
            this.fetchLabels();
          })
          .catch((error) => {
            this.errors.push(error.response.data.message);
          });
      }
    },
    testPrint(e) {
      e.preventDefault();
    },
  },
});
