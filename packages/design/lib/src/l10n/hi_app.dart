/// Sign-in, the gates, and the screens that belong to neither audience.
library;

const hiApp = <String, String>{
  // ---- splash and the locks ----
  'Resolving your session…': 'आपका सेशन देखा जा रहा है…',
  'InterioBee is locked': 'InterioBee लॉक है',

  /// The lock is on the *UI*, not the session. The Hindi has to say the
  /// session is still alive, or somebody reads this as having been signed out
  /// and starts again from their number.
  'Your session is still active. Unlock to carry on.':
      'आपका सेशन अब भी चालू है। आगे बढ़ने के लिए अनलॉक करें।',
  'Unlock': 'अनलॉक करें',
  'Sign out instead': 'इसके बजाय साइन आउट करें',
  'Sign out': 'साइन आउट',

  // ---- staff, refused ----
  'Staff sign in on the web': 'स्टाफ़ वेब पर साइन इन करते हैं',
  'This app is for customers and professionals. Ops and admin work from the web panel, which has the tools this one does not.':
      'यह ऐप ग्राहकों और कारीगरों के लिए है। ऑप्स और एडमिन का काम वेब पैनल से होता है, जहाँ वे सुविधाएँ हैं जो इसमें नहीं हैं।',

  // ---- sign in ----
  ///
  /// There is no "sign up" anywhere in the product, and the Hindi must not
  /// invent one: an unrecognised number creates an account, and saying so
  /// plainly is what replaces the missing button.
  'Interior design, furniture, fabrication and painting — with one person who answers.':
      'इंटीरियर डिज़ाइन, फ़र्नीचर, फ़ैब्रिकेशन और पेंटिंग — और एक इंसान जो जवाब देता है।',
  'Mobile number': 'मोबाइल नंबर',
  'Send code': 'कोड भेजें',
  'New here? Entering your number is all it takes — we will set the account up as you go.':
      'पहली बार आए हैं? बस अपना नंबर डालिए — खाता हम साथ-साथ बना देंगे।',
  'or': 'या',
  'Continue with Google': 'Google से जारी रखें',

  /// Google gives a verified email and a name, never a phone number, and ops
  /// ring every customer about their lead. The Hindi says why the number is
  /// wanted rather than simply asking again, which would read as a form that
  /// had gone backwards.
  'Signed in with Google. One number and you are done.':
      'Google से साइन इन हो गया। बस एक नंबर और, फिर काम पूरा।',
  'We use it to reach you about your quotes, nothing else.':
      'इसका इस्तेमाल सिर्फ़ आपके कोटेशन के बारे में बात करने के लिए होगा, और किसी काम के लिए नहीं।',
  'We sent a code to {number}.': 'हमने {number} पर कोड भेजा है।',
  'Send again': 'दोबारा भेजें',
  'Change number': 'नंबर बदलें',
  'Your number is verified. Two things and you are in.':
      'आपका नंबर जाँच लिया गया। दो चीज़ें और, फिर आप अंदर हैं।',
  'Your name': 'आपका नाम',
  'Too many attempts.': 'बहुत बार कोशिश हो चुकी।',
  '{error} Try again in {n}s.': '{error} {n} सेकंड बाद दोबारा कोशिश करें।',
  'You were signed out': 'आपको साइन आउट कर दिया गया था',

  // ---- language ----
  'Language': 'भाषा',

  /// "Same as your phone" rather than "अपने आप": this is the device setting,
  /// and a person changing it needs to know where the setting lives.
  'Same as your phone': 'जैसा आपके फ़ोन में है',

  // ---- closing an account ----
  ///
  /// Two rules the Hindi keeps. It does not soften "cannot be undone", and it
  /// is as exact as the English about what stays — somebody who expected
  /// erasure and later finds an invoice with their agreement on it would
  /// rightly feel misled.
  'Close your account': 'अपना खाता बंद करें',
  'This cannot be undone. Your name, number and address are removed, and you are signed out everywhere.':
      'यह वापस नहीं हो सकता। आपका नाम, नंबर और पता हटा दिए जाएँगे, और आप हर जगह से साइन आउट हो जाएँगे।',
  'What stays': 'क्या रहेगा',
  'And why': 'और क्यों',
  'Agreements, invoices and reviews are kept.':
      'एग्रीमेंट, बिल और रिव्यू रखे जाएँगे।',
  'Each of these has a professional on the other side of it, and they did not ask for their records to be destroyed. What is kept no longer carries your name or your number.':
      'इनमें से हर एक के दूसरी तरफ़ एक कारीगर है, और उन्होंने अपना रिकॉर्ड मिटाने को नहीं कहा। जो रखा जाएगा उस पर अब आपका नाम या नंबर नहीं रहेगा।',
  'Why are you leaving?': 'आप क्यों जा रहे हैं?',
  'It helps us, and it is not required.':
      'इससे हमें मदद मिलती है, और यह ज़रूरी नहीं है।',
  'Confirm': 'पुष्टि करें',
  'Type it exactly': 'बिलकुल वैसा ही लिखें',

  /// DELETE stays in English inside the Hindi. `_confirmed` matches it
  /// character for character against the literal the contract types, so a
  /// translated word would never enable the button.
  'Type DELETE to confirm': 'पुष्टि के लिए DELETE लिखें',
  'Close my account permanently': 'मेरा खाता हमेशा के लिए बंद करें',
  'Keep my account': 'मेरा खाता रहने दें',
  'Account closed': 'खाता बंद हो गया',
  'Your personal details have been removed, and your number is free to use again if you ever come back.':
      'आपकी निजी जानकारी हटा दी गई है, और आपका नंबर दोबारा इस्तेमाल के लिए खाली है — अगर आप कभी लौटें।',
  'What we kept': 'हमने क्या रखा',
  'As explained': 'जैसा बताया गया',
  'These no longer carry your name or your number.':
      'इन पर अब आपका नाम या नंबर नहीं है।',

  // ---- the forced upgrade ----
  'Update InterioBee': 'InterioBee अपडेट करें',
  'Open the app store': 'ऐप स्टोर खोलें',
  'Your account and anything in progress are safe. This build just cannot talk to InterioBee any more.':
      'आपका खाता और चल रहा काम सुरक्षित है। बस यह वर्ज़न अब InterioBee से बात नहीं कर सकता।',
  'Search for "InterioBee" in your app store to update.':
      'अपडेट के लिए अपने ऐप स्टोर में "InterioBee" खोजें।',
};
