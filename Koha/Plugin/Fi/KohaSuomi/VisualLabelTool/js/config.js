import printView from './printView.js';
import margins from './margins.js';
import errorComp from './errors.js';
import { t, setLang } from './translations.js';

// Set language based on browser or user preference
const browserLang = (pageLang || navigator.language || navigator.userLanguage || 'en').substring(0,2);
setLang(['en', 'fi', 'sv'].includes(browserLang) ? browserLang : 'en');

const Multiselect = Vue.component(
  'vue-multiselect',
  window.VueMultiselect.default
);

new Vue({
  el: '#configApp',
  components: {
    Multiselect,
    printView,
    margins,
    errorComp,
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
      { name: t('A4/14'), value: '14' },
      { name: t('A4/12'), value: '12' },
      { name: t('A4/10'), value: '10' },
      { name: t('Rulla'), value: 'roll' },
      { name: t('A4/signum'), value: 'signum' },
    ],
    showSignum: false,
    selectedType: null,
    fields: [],
    showField: false,
    showTest: false,
    prints: [],
    isDisabled: true,
    fontFamilies: [
      'Arial',
      'Verdana',
      'Courier',
      'Tahoma',
      'Trebuchet MS',
      'Helvetica',
    ],
    fontWeights: ['normal', 'bold'],
    whiteSpaces: ['normal', 'nowrap'],
    overflow: ['visible', 'hidden'],
    topMargin: 0,
    leftMargin: 0,
    loader: false,
    fileName: '',
    showInfo: false,
  },
  created() {
    this.fetchLabels();
    this.fetchFields();
  },
  computed: {
    pageMargins: function () {
      return (
        '@page {margin-top: ' +
        this.topMargin +
        '; margin-left: ' +
        this.leftMargin +
        ';}'
      );
    },
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
    updateFieldName(e) {
      this.selectedField.name = e.target.value;
    },
    removeFromLabels() {
      if (this.showTab == 'labelFields') {
        this.label.fields.forEach((element, index) => {
          if (element.name == this.selectedField.name && !element.id) {
            this.label.fields.splice(index, 1);
          } else if (element.id == this.selectedField.id) {
            this.label.fields.splice(index, 1);
          }
        });
      } else {
        this.label.signum.fields.forEach((element, index) => {
          if (element.name == this.selectedField.name && !element.id) {
            this.label.signum.fields.splice(index, 1);
          } else if (element.id == this.selectedField.id) {
            this.label.signum.fields.splice(index, 1);
          }
        });
      }
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
    addField(type) {
      this.selectedField = undefined;
      const object = Object.create({});
      object.name = this.fieldName;
      if (this.fieldName == 'custom') {
        this.isDisabled = false;
      }
      object.dimensions = {
        top: '0mm',
        left: '0mm',
        right: '0mm',
        fontSize: '14px',
      };
      this.selectedField = object;
      if (type == 'signum') {
        if (this.label.signum.fields) {
          this.label.signum.fields.push(this.selectedField);
        } else {
          this.label.signum.fields = [];
          this.label.signum.fields.push(this.selectedField);
        }
      } else {
        if (this.label.fields) {
          this.label.fields.push(this.selectedField);
        } else {
          this.label.fields = [];
          this.label.fields.push(this.selectedField);
        }
      }
      this.fieldName = '';
      this.showField = true;
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
      this.fieldName = '';
      this.showTab = val;
    },
    showFieldData(e) {
      this.showField = true;
      const prefix = this.selectedField.name.split('.');
      if (
        prefix[0] != 'marc' &&
        prefix[0] != 'items' &&
        prefix[0] != 'biblio' &&
        prefix[0] != 'biblioitems'
      ) {
        this.isDisabled = false;
      } else {
        this.isDisabled = true;
      }
    },
    fetchLabels() {
      this.errors = [];
      this.showInfo = false;
      axios
        .get('/api/v1/contrib/kohasuomi/labels')
        .then((response) => {
          this.savedLabels = response.data;
        })
        .catch((error) => {
          this.errors.push(error);
        });
    },
    fetchFields() {
      this.errors = [];
      axios
        .get('/api/v1/contrib/kohasuomi/labels/fields')
        .then((response) => {
          this.fields = response.data;
        })
        .catch((error) => {
          this.errors.push(error);
        });
    },
    saveLabel(e) {
      e.preventDefault();
      this.errors = [];
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
          this.errors.push(error);
        });
    },
    updateLabel(e) {
      e.preventDefault();
      this.errors = [];
      this.saved = false;
      axios
        .put('/api/v1/contrib/kohasuomi/labels/' + this.label.id, this.label)
        .then((response) => {
          this.label = response.data;
          this.saved = true;
        })
        .catch((error) => {
          this.errors.push(error);
        });
    },
    deleteLabel(e) {
      e.preventDefault();
      this.errors = [];
      if (confirm(t('Haluatko varmasti poistaa tarran') + ' ' + this.label.name)) {
        axios
          .delete('/api/v1/contrib/kohasuomi/labels/' + this.label.id)
          .then(() => {
            this.label = null;
            this.saved = false;
            this.fetchLabels();
          })
          .catch((error) => {
            this.errors.push(error);
          });
      }
    },
    deleteField(e) {
      e.preventDefault();
      this.errors = [];
      if (
        this.selectedField.id &&
        confirm(t('Haluatko varmasti poistaa kentän') + ' ' + this.selectedField.name)
      ) {
        axios
          .delete(
            '/api/v1/contrib/kohasuomi/labels/fields/' + this.selectedField.id
          )
          .then(() => {
            this.removeFromLabels();
            this.selectedField = undefined;
            this.showField = false;
          })
          .catch((error) => {
            this.errors.push(error);
          });
      } else {
        this.removeFromLabels();
        this.selectedField = undefined;
        this.showField = false;
      }
    },
    exportLabel(e) {
      e.preventDefault();
      const labelData = JSON.stringify(this.label, null, 2);
      const blob = new Blob([labelData], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      const date = new Date().toISOString().split('T')[0];
      link.download = `${this.label.name || 'label'}_${date}.json`;
      link.click();
      URL.revokeObjectURL(url);
    },
    importLabel(e) {
      e.preventDefault();
      this.errors = [];
      this.fileName = '';
      this.updateButton = false;
      this.label = null;
      const fileInput = document.getElementById('import');
      const file = fileInput.files[0];
      if (file) {
        this.fileName = file.name;
        const reader = new FileReader();
        reader.onload = (event) => {
          try {
            const labelData = JSON.parse(event.target.result);
            this.label = labelData;
            this.label.name = this.fileName;
            this.showTabs('labelSettings');
            this.showInfo = true;
          } catch (error) {
            const message =
              t('Tiedoston muoto ei ole oikea. Varmista, että tiedosto on JSON-muodossa.');
            this.errors.push({
              message: message,
              response: { data: { message: message } },
            });
            this.showInfo = false;
            this.label = null;
          }
        };
        reader.readAsText(file);
      }
    },
    testPrint(e) {
      e.preventDefault();
      this.errors = [];
      var searchParams = new URLSearchParams();
      searchParams.append('test', true);
      axios
        .post('/api/v1/contrib/kohasuomi/labels/print/' + this.label.id, [], {
          params: searchParams,
        })
        .then((response) => {
          this.prints = response.data;
          this.showTest = true;
        })
        .catch((error) => {
          this.errors.push(error);
        });
    },
    back() {
      this.showTest = false;
    },
    printTest() {
      this.topMargin = localStorage.getItem('LabelToolTopMargin')
        ? parseInt(localStorage.getItem('LabelToolTopMargin'))
        : 0;
      this.leftMargin = localStorage.getItem('LabelToolLeftMargin')
        ? parseInt(localStorage.getItem('LabelToolLeftMargin'))
        : 0;
      let paddingTop = parseInt(this.label.dimensions.paddingTop) ? parseInt(this.label.dimensions.paddingTop) : 0;
      let paddingBottom = parseInt(this.label.dimensions.paddingBottom) ? parseInt(this.label.dimensions.paddingBottom) : 0;
      let signumWidth = this.label.signum && parseInt(this.label.signum.dimensions.width) ? parseInt(this.label.signum.dimensions.width) : 0
      this.loader = true;
      let element = document.getElementById('printLabel');
      let rollWidth = parseInt(this.label.dimensions.width) + signumWidth;
      let rollHeight = parseInt(this.label.dimensions.height)+ paddingTop + paddingBottom + this.topMargin;
      let pdfFormat = this.label.type == 'roll' ? [rollHeight, rollWidth] : 'a4';
      let pdfOrientation = this.label.type == 'roll' ? 'l' : 'p';
      var opt = {
        margin: [this.topMargin, this.leftMargin, 0, 0],
        filename:     'printLabel.pdf',
        image:        { type: 'jpeg', quality: 1 },
        html2canvas:  { scale: 4, logging: true},
        jsPDF:        { orientation: pdfOrientation, unit: 'mm', format: pdfFormat},
      };
      html2pdf().set(opt).from(element).save().then(() =>{
        this.loader = false;
      });
    },
    t // Make translation function available in template
  },
});
