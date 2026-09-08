/// The estimator and the guides.
///
/// Split out from `hi_customer.dart` because it is a different translation job:
/// the estimator's table is trade vocabulary — फ़िनिश, बीओक्यू, रनिंग फ़ीट —
/// and the guides are editorial prose. A translator reviewing prices should not
/// have to scroll past article copy to find them.
///
/// The one rule that outranks fluency here: the estimator's bracket language
/// must not harden. `bracket`, `rough`, `estimate` all soften in Hindi if
/// translated politely, and the whole design of that screen is an argument
/// against a customer reading a precise number. `अंदाज़ा` and `मोटा-मोटी` carry
/// the hedge; `कीमत` does not, and is avoided.
library;

const hiGuides = <String, String>{
  // ---- the estimator, chrome ----
  'Rough cost': 'मोटा-मोटी ख़र्च',
  'What might this cost?': 'इसमें कितना लग सकता है?',
  'A bracket to plan around, worked out from the same rates our professionals quote at. It needs no account and no phone number.':
      'योजना बनाने के लिए एक अंदाज़ा, उन्हीं दरों से निकाला गया जिन पर हमारे कारीगर कोटेशन देते हैं। इसके लिए न खाता चाहिए, न फ़ोन नंबर।',
  'Drag to change': 'बदलने के लिए खिसकाएँ',
  'Finish level': 'फ़िनिश का स्तर',
  'Moves the figure most': 'यही आँकड़े को सबसे ज़्यादा बदलता है',
  'Rough range': 'अंदाज़न सीमा',
  'Midpoint {amount}': 'बीच का आँकड़ा {amount}',

  /// The sentence the whole screen exists to make believable.
  'This is a bracket, not a quote': 'यह अंदाज़ा है, कोटेशन नहीं',
  'Real prices come from a site visit. Three professionals will each measure the job and quote against the same brief — that is the number to decide on.':
      'असली दाम साइट विज़िट से तय होते हैं। तीन कारीगर ख़ुद नाप लेंगे और एक ही ब्यौरे पर कोटेशन देंगे — फ़ैसला उसी आँकड़े पर कीजिए।',
  'Not included': 'इसमें शामिल नहीं',
  'Get a real quote, free': 'असली कोटेशन मँगाएँ, मुफ़्त',

  // ---- units ----
  'bedroom': 'बेडरूम',
  'bedrooms': 'बेडरूम',
  'piece': 'नग',
  'pieces': 'नग',
  'sq.ft carpet area': 'वर्ग फुट कारपेट एरिया',
  'running ft': 'रनिंग फ़ीट',

  // ---- interior design ----
  'Turnkey interiors are quoted per project against a BOQ. This estimate is anchored on home size and the finish level you choose.':
      'टर्नकी इंटीरियर का कोटेशन पूरे प्रोजेक्ट का, बीओक्यू के हिसाब से बनता है। यह अंदाज़ा घर के आकार और आपके चुने फ़िनिश पर टिका है।',
  'Bedrooms': 'बेडरूम',
  '1BHK through 5BHK or villa': '1BHK से 5BHK या विला तक',
  'Essential': 'ज़रूरी',
  'Kitchen, wardrobes, TV unit': 'रसोई, अलमारी, टीवी यूनिट',
  'Premium': 'प्रीमियम',
  'Adds ceiling, lighting, panelling': 'सीलिंग, लाइटिंग और पैनलिंग भी',
  'Luxury': 'लक्ज़री',
  'Bespoke detailing throughout': 'पूरे घर में ख़ास डिज़ाइन',
  'Excludes civil, plumbing and electrical rework.':
      'सिविल, प्लंबिंग और बिजली का दोबारा काम इसमें नहीं है।',
  'Excludes appliances and loose furniture.':
      'उपकरण और खुला फ़र्नीचर इसमें नहीं है।',
  'A real figure comes from the BOQ after the site visit — this is only a bracket.':
      'असली आँकड़ा साइट विज़िट के बाद बीओक्यू से आता है — यह सिर्फ़ एक अंदाज़ा है।',

  // ---- furniture ----
  'Furniture is priced per piece, or per sq.ft of shutter area for storage. This estimates a typical mix of wardrobe, bed and unit work.':
      'फ़र्नीचर का दाम प्रति नग लगता है, या स्टोरेज के लिए शटर एरिया के वर्ग फुट पर। यह अलमारी, पलंग और यूनिट के आम मेल का अंदाज़ा है।',
  'Number of pieces': 'कितने नग',
  'Wardrobes, beds, units — count each item':
      'अलमारी, पलंग, यूनिट — हर चीज़ गिनिए',
  'Laminate': 'लैमिनेट',
  'BWR ply, laminate finish': 'बीडब्ल्यूआर प्लाई, लैमिनेट फ़िनिश',
  'Membrane / veneer': 'मेम्ब्रेन / विनियर',
  'Seamless or natural finish': 'बिना जोड़ या क़ुदरती फ़िनिश',
  'Acrylic / PU': 'एक्रिलिक / पीयू',
  'Premium finish, soft-close throughout':
      'प्रीमियम फ़िनिश, हर जगह सॉफ़्ट-क्लोज़',
  'Assumes standard sizes. Floor-to-ceiling and loft work costs more.':
      'आम नाप मानकर चला गया है। फ़र्श से छत तक और लॉफ़्ट का काम महँगा पड़ता है।',
  'Excludes loose furniture, mattresses and soft furnishing.':
      'खुला फ़र्नीचर, गद्दे और सॉफ़्ट फ़र्निशिंग इसमें नहीं हैं।',
  'If you supply the board yourself, expect roughly 30% less.':
      'अगर बोर्ड आप ख़ुद देंगे तो क़रीब 30% कम लगेगा।',

  // ---- fabrication ----
  'Fabrication is priced per running foot or per sq.ft of fabricated area, and the metal you choose moves the figure more than anything else.':
      'फ़ैब्रिकेशन का दाम रनिंग फ़ीट या बने हुए हिस्से के वर्ग फुट पर लगता है, और आँकड़ा सबसे ज़्यादा आपके चुने धातु से बदलता है।',
  'Approximate running feet': 'क़रीब कितने रनिंग फ़ीट',
  'Total of gates, grills and railings': 'गेट, ग्रिल और रेलिंग सब मिलाकर',
  'MS, enamel': 'एमएस, इनैमल',
  'Mild steel, painted on site': 'माइल्ड स्टील, साइट पर पेंट',
  'MS, powder coated': 'एमएस, पाउडर कोटेड',
  'Workshop finish, lasts far longer': 'वर्कशॉप फ़िनिश, कहीं ज़्यादा टिकती है',
  'Stainless 304': 'स्टेनलेस 304',
  'No rust, no repainting': 'न जंग, न दोबारा पेंट',
  'Design complexity matters — laser-cut panels and glass infill add substantially.':
      'डिज़ाइन की पेचीदगी मायने रखती है — लेज़र-कट पैनल और शीशे का भराव काफ़ी बढ़ा देते हैं।',
  'Excludes motorisation, civil work and site preparation.':
      'मोटर लगाना, सिविल काम और साइट की तैयारी इसमें नहीं हैं।',
  'Site measurement will change the running feet, usually upward.':
      'साइट पर नाप लेने से रनिंग फ़ीट बदलेंगे, अक्सर बढ़ेंगे।',

  // ---- painting ----
  'Painting is priced on painted area. A 1000 sq.ft carpet-area flat has roughly 3,200 sq.ft of wall and ceiling to paint.':
      'पेंटिंग का दाम पुते हुए हिस्से पर लगता है। 1000 वर्ग फुट कारपेट एरिया के फ़्लैट में क़रीब 3,200 वर्ग फुट दीवार और छत पुतती है।',
  'Carpet area': 'कारपेट एरिया',
  'We convert this to painted area at roughly 3.2×':
      'हम इसे क़रीब 3.2× करके पुताई का क्षेत्रफल निकालते हैं',
  'Repaint': 'दोबारा पुताई',
  'Walls already puttied, minor repair': 'दीवारों पर पुट्टी है, थोड़ी मरम्मत',
  'Repaint + full putty': 'दोबारा पुताई + पूरी पुट्टी',
  'Two coats putty and sanding': 'दो कोट पुट्टी और रगड़ाई',
  'Fresh painting': 'नई पुताई',
  'New plaster, full system': 'नया प्लास्टर, पूरा सिस्टम',
  'Assumes premium emulsion. A luxury product line adds roughly 40%.':
      'प्रीमियम इमल्शन मानकर चला गया है। लक्ज़री रेंज क़रीब 40% बढ़ा देती है।',
  'Excludes exterior walls, texture finishes and waterproofing.':
      'बाहरी दीवारें, टेक्सचर फ़िनिश और वॉटरप्रूफ़िंग इसमें नहीं हैं।',
  'Excludes wood and metal polishing.': 'लकड़ी और धातु की पॉलिश इसमें नहीं है।',

  // ---- the guides ----
  'Guides': 'गाइड',
  'What things cost': 'चीज़ों का ख़र्च',
  'No account needed': 'खाते की ज़रूरत नहीं',
  'What things cost, how long they take, and what to ask before you agree to any of it.':
      'किस चीज़ में कितना लगता है, कितना समय लगता है, और हाँ कहने से पहले क्या पूछना चाहिए।',
  'Nothing here yet': 'अभी यहाँ कुछ नहीं',
  'No guides in this section. Try another, or come back — we add to these.':
      'इस हिस्से में कोई गाइड नहीं। कोई और देखिए, या बाद में आइए — हम इनमें जोड़ते रहते हैं।',
  '{n} min read': '{n} मिनट में पढ़ें',
  '{author}, {role} · {n} min read': '{author}, {role} · {n} मिनट में पढ़ें',
  'Read next': 'आगे पढ़ें',
  'Related': 'मिलती-जुलती',
  'Thinking about this for your own place?': 'अपने घर के लिए सोच रहे हैं?',
  'Tell us what you need and we will find you three verified professionals. It costs nothing to ask.':
      'बताइए आपको क्या चाहिए, हम आपके लिए तीन जाँचे हुए कारीगर ढूँढ़ेंगे। पूछने का कोई पैसा नहीं लगता।',
};
