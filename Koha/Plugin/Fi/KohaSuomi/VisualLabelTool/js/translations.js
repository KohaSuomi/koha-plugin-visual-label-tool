const translations = {
    'Oma tulostusjono': {
        en: 'Own print queue',
        fi: 'Oma tulostusjono',
        sv: 'Egen utskriftskö'
    },
    'Tänään vastaanotetut': {
        en: 'Received today',
        fi: 'Tänään vastaanotetut',
        sv: 'Mottagna idag'
    },
    'Tänään vastaanotetut kausijulkaisut': {
        en: 'Received serials today',
        fi: 'Tänään vastaanotetut kausijulkaisut',
        sv: 'Mottagna tidskrifter idag'
    },
    'Itse tulostetut': {
        en: 'Printed by self',
        fi: 'Itse tulostetut',
        sv: 'Själv utskrivna'
    },
    'Haluatko varmasti poistaa niteen': {
        en: 'Are you sure you want to remove item',
        fi: 'Haluatko varmasti poistaa niteen',
        sv: 'Vill du verkligen ta bort exemplaret'
    },
    'Ylämarginaali': {
        en: 'Top margin',
        fi: 'Ylämarginaali',
        sv: 'Övre marginal'
    },
    'Ylämarginaali(mm)': {
        en: 'Top margin (mm)',
        fi: 'Ylämarginaali(mm)',
        sv: 'Övre marginal (mm)'
    },
    'Vasen marginaali': {
        en: 'Left margin',
        fi: 'Vasen marginaali',
        sv: 'Vänster marginal'
    },
    'Vasen marginaali(mm)': {
        en: 'Left margin (mm)',
        fi: 'Vasen marginaali(mm)',
        sv: 'Vänster marginal (mm)'
    },
    'Tapahtui virhe:': {
        en: 'An error occurred:',
        fi: 'Tapahtui virhe:',
        sv: 'Ett fel inträffade:'
    },
    'A4/14': {
        en: 'A4/14',
        fi: 'A4/14',
        sv: 'A4/14'
    },
    'A4/12': {
        en: 'A4/12',
        fi: 'A4/12',
        sv: 'A4/12'
    },
    'A4/10': {
        en: 'A4/10',
        fi: 'A4/10',
        sv: 'A4/10'
    },
    'Rulla': {
        en: 'Roll',
        fi: 'Rulla',
        sv: 'Rulle'
    },
    'A4/signum': {
        en: 'A4/signum',
        fi: 'A4/signum',
        sv: 'A4/signum'
    },
    'Haluatko varmasti poistaa tarran': {
        en: 'Are you sure you want to delete the label',
        fi: 'Haluatko varmasti poistaa tarran',
        sv: 'Vill du verkligen ta bort etiketten'
    },
    'Haluatko varmasti poistaa kentän': {
        en: 'Are you sure you want to delete the field',
        fi: 'Haluatko varmasti poistaa kentän',
        sv: 'Vill du verkligen ta bort fältet'
    },
    'Tiedoston muoto ei ole oikea. Varmista, että tiedosto on JSON-muodossa.': {
        en: 'File format is incorrect. Please make sure the file is in JSON format.',
        fi: 'Tiedoston muoto ei ole oikea. Varmista, että tiedosto on JSON-muodossa.',
        sv: 'Filformatet är felaktigt. Kontrollera att filen är i JSON-format.'
    }
};

let currentLang = 'en';

export function setLang(lang) {
  if (['en', 'fi', 'sv'].includes(lang)) {
    currentLang = lang;
  } else {
    currentLang = 'en';
  }
}

export function t(key) {
  if (translations[key]) {
    return translations[key][currentLang] || translations[key]['en'] || key;
  }
  return key;
}
