import printView from './printView.js';
import margins from './margins.js';
import errorComp from './errors.js';
const Multiselect = Vue.component(
  'vue-multiselect',
  window.VueMultiselect.default
);

new Vue({
  el: '#viewApp',
  components: {
    Multiselect,
    printView,
    margins,
    errorComp,
  },
  created() {
    this.fetchLabels();
  },
  data: {
    errors: [],
    savedLabels: [],
    items: [],
    prints: [],
    labels: [],
    label: null,
    showPrinting: false,
    printingType: [
      { name: 'Oma tulostusjono', value: 'list' },
      { name: 'Tänään vastaanotettu', value: 'received' },
      { name: 'Itse tulostetut', value: 'printed' },
    ],
    type: null,
    barcode: '',
    topMargin: 0,
    leftMargin: 0,
    loader: false
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
    fetchLabels() {
      this.errors = [];
      axios
        .get('/api/v1/contrib/kohasuomi/labels')
        .then((response) => {
          this.savedLabels = response.data;
        })
        .catch((error) => {
          this.errors.push(error);
        });
    },
    fetchItems() {
      this.errors = [];
      this.items = [];
      var searchParams = new URLSearchParams();
      searchParams.append('type', this.type.value);
      axios
        .get('/api/v1/contrib/kohasuomi/labels/print/queue', {
          params: searchParams,
        })
        .then((response) => {
          this.items = response.data;
        })
        .catch((error) => {
          this.errors.push(error);
        });
    },
    back() {
      this.showPrinting = false;
    },
    printLabels(e) {
      e.preventDefault();
      this.errors = [];
      var searchParams = new URLSearchParams();
      searchParams.append('test', false);
      axios
        .post(
          '/api/v1/contrib/kohasuomi/labels/print/' + this.label.id,
          this.prints,
          {
            params: searchParams,
          }
        )
        .then((response) => {
          this.labels = response.data;
          this.showPrinting = true;
        })
        .catch((error) => {
          this.errors.push(error);
        });
    },
    print() {
      this.topMargin = localStorage.getItem('LabelToolTopMargin')
        ? parseInt(localStorage.getItem('LabelToolTopMargin'))
        : 0;
      this.leftMargin = localStorage.getItem('LabelToolLeftMargin')
        ? parseInt(localStorage.getItem('LabelToolLeftMargin'))
        : 0;
      this.loader = true;
      let element = document.getElementById('printLabel');
      let rollWidth = parseInt(this.label.dimensions.width)+parseInt(this.label.signum.dimensions.width);
      let rollHeight = parseInt(this.label.dimensions.height)+parseInt(this.label.dimensions.paddingTop)+parseInt(this.label.dimensions.paddingBottom)+this.topMargin;
      let pdfFormat = this.label.type == 'roll' ? [rollHeight, rollWidth] : 'a4';
      let pdfOrientation = this.label.type == 'roll' ? 'l' : 'p';
      var opt = {
        margin: [this.topMargin, this.leftMargin, 0, 0],
        filename:     'printLabel.pdf',
        image:        { type: 'png', quality: 0.40 },
        html2canvas:  { scale: 2},
        jsPDF:        { orientation: pdfOrientation, unit: 'mm', format: pdfFormat},
      };
      html2pdf().set(opt).from(element).save().then(() =>{
        this.updatePrintQueue();
        this.loader = false;
      });
    },
    removeFromPrint(index) {
      this.prints.splice(index, 1);
    },
    removeFromItems(index) {
      this.errors = [];
      if (
        confirm('Haluatko varmasti poistaa niteen ' + this.items[index].barcode)
      ) {
        axios
          .delete(
            '/api/v1/contrib/kohasuomi/labels/print/queue/' +
              this.items[index].queue_id
          )
          .then(() => {
            this.items.splice(index, 1);
          })
          .catch((error) => {
            this.errors.push(error);
          });
      }
    },
    addToPrints(index) {
      if (index >= 0) {
        this.prints.push(this.items[index]);
      } else {
        this.items.forEach((element) => {
          this.prints.push(element);
        });
      }
    },
    clearPrints() {
      this.prints = [];
    },
    setBarcode() {
      const barcodeArray = this.barcode.split(" ");
      if (barcodeArray.length) {
        barcodeArray.forEach((element) => {
          this.prints.push({ barcode: element });
        });
      } else {
        let element = { barcode: this.barcode };
        this.prints.push(element);
      }
      this.barcode = '';
    },
    async updatePrintQueue() {
      this.errors = [];
      const promises = [];
      this.prints.forEach((element) => {
        promises.push(
          axios
            .put('/api/v1/contrib/kohasuomi/labels/print/queue', {
              itemnumber: element.itemnumber,
              barcode: element.barcode,
              printed: 1,
              queue_id: element.queue_id,
            })
            .then(() => {})
            .catch((error) => {
              this.errors.push(error);
            })
        );
      });
      await Promise.all(promises).then(() => {
        this.clearPrints();
      });
    },
  },
});
