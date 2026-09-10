/// Asking to become a vendor, and hearing back.
///
/// Its own section because it sits between the two halves of the app and
/// belongs to neither. The person reading it is a customer as far as the
/// database is concerned and a carpenter as far as they are concerned, and the
/// Hindi has to work for both — so it uses the trade vocabulary of
/// `hi_vendor.dart` (`ट्रेड`, `लीड`, `कमीशन`) while still explaining itself to
/// somebody who has never seen the professional portal.
///
/// Two things are said bluntly on purpose, because softening either is how
/// somebody ends up waiting for a call that will not come:
///
///   * a professional account is *made by our team*, never by signing up;
///   * signing in with a number nobody approved opens the customer view.
library;

const hiApply = <String, String>{
  // ---- the two audiences on sign-in ----
  'Your leads, quotes, site visits and commission live in the professional portal. The code goes to the number your account is registered against.':
      'आपकी लीड, कोटेशन, साइट विज़िट और कमीशन — सब प्रोफ़ेशनल पोर्टल में हैं। कोड उसी नंबर पर आएगा जिस पर आपका खाता रजिस्टर्ड है।',
  'Professional accounts are created by our team after an application is approved — signing in with a number we have not approved will open the customer view.':
      'प्रोफ़ेशनल खाता हमारी टीम बनाती है, आवेदन मंज़ूर होने के बाद। जिस नंबर को हमने मंज़ूर नहीं किया, उससे साइन इन करने पर ग्राहक वाला व्यू ही खुलेगा।',
  'Not registered yet? Apply to join': 'अभी रजिस्टर्ड नहीं हैं? आवेदन करें',

  // ---- what sign-in says when the number is not a vendor's ----
  'Not a professional account': 'यह प्रोफ़ेशनल खाता नहीं है',
  'You are signed in, but this number is not registered as a professional. Professional accounts are created by our team after an application is approved — you cannot sign up for one directly.':
      'आप साइन इन हैं, लेकिन यह नंबर प्रोफ़ेशनल के तौर पर रजिस्टर्ड नहीं है। प्रोफ़ेशनल खाता हमारी टीम आवेदन मंज़ूर होने के बाद बनाती है — इसके लिए सीधे साइन अप नहीं किया जा सकता।',

  // ---- the form ----
  'Tell us about your business': 'अपने काम के बारे में बताइए',
  'Update your application': 'अपना आवेदन अपडेट कीजिए',
  'Our team reads every application. Nothing here is published anywhere until you are approved.':
      'हमारी टीम हर आवेदन पढ़ती है। मंज़ूरी मिलने तक यहाँ की कोई बात कहीं नहीं दिखाई जाती।',
  'Business name': 'काम का नाम',
  'e.g. Sri Balaji Interiors': 'जैसे श्री बालाजी इंटीरियर्स',
  'Years in the trade': 'इस काम में कितने साल',
  'e.g. 8': 'जैसे 8',
  'A whole number of years, up to 70': 'पूरे साल में लिखिए, 70 तक',
  'Who should we ask for?': 'किससे बात करें?',
  'The person who takes our calls': 'जो हमारा फ़ोन उठाएँगे',
  'Best number to reach you': 'बात करने के लिए सबसे सही नंबर',
  'Leave blank to use the number on your account':
      'खाली छोड़ेंगे तो खाते वाला नंबर ले लिया जाएगा',
  'GST number': 'जीएसटी नंबर',
  'Optional — not required for smaller workshops':
      'ज़रूरी नहीं — छोटी वर्कशॉप के लिए इसकी माँग नहीं है',

  'Which trades do you want leads for?': 'किन ट्रेड की लीड चाहिए?',
  'Approval is per trade': 'मंज़ूरी हर ट्रेड के लिए अलग',
  'Could not load the trades.': 'ट्रेड की सूची नहीं आ सकी।',
  'Where do you work?': 'आप कहाँ काम करते हैं?',
  'Leads are matched by city': 'लीड शहर के हिसाब से मिलती हैं',
  'Could not load the cities.': 'शहरों की सूची नहीं आ सकी।',

  'Localities, in your own words': 'इलाक़े, अपने शब्दों में',
  'e.g. Anywhere in south Lucknow; Kanpur for big jobs':
      'जैसे दक्षिण लखनऊ में कहीं भी; कानपुर सिर्फ़ बड़े काम के लिए',
  'What kind of work do you do?': 'आप किस तरह का काम करते हैं?',
  'The jobs you take on, the size of your team, and a couple of recent projects.':
      'कैसे काम लेते हैं, टीम में कितने लोग हैं, और हाल के दो-एक प्रोजेक्ट।',
  '{n} more characters': '{n} अक्षर और',
  'Good. Specifics get read properly.': 'ठीक है। ब्यौरा हो तो पढ़ा ठीक से जाता है।',

  'Approval switches this account over to the professional portal, where your leads, quotes and commission live.':
      'मंज़ूरी मिलते ही यह खाता प्रोफ़ेशनल पोर्टल पर चला जाएगा, जहाँ आपकी लीड, कोटेशन और कमीशन रहते हैं।',
  'Send application': 'आवेदन भेजें',
  'Send updated application': 'अपडेट किया आवेदन भेजें',
  'Sending…': 'भेजा जा रहा है…',

  // ---- waiting ----
  'Application received': 'आवेदन मिल गया',
  'Being reviewed': 'देखा जा रहा है',
  'Your application is with our team': 'आपका आवेदन हमारी टीम के पास है',
  'Our team is looking at this now': 'हमारी टीम अभी इसे देख रही है',
  'We read applications in the order they arrive and usually come back within two working days, by phone.':
      'आवेदन जिस क्रम में आते हैं उसी क्रम में देखे जाते हैं। आम तौर पर दो कामकाजी दिन के अंदर फ़ोन पर जवाब मिल जाता है।',
  'Business': 'काम',
  'Trades applied for': 'जिन ट्रेड के लिए आवेदन किया',
  'Changed your mind, or sent the wrong details? Withdraw this and you can apply again whenever you like.':
      'मन बदल गया, या ब्यौरा ग़लत चला गया? इसे वापस ले लीजिए — दोबारा जब चाहें आवेदन कर सकते हैं।',
  'Withdraw application': 'आवेदन वापस लें',
  'Withdrawing…': 'वापस लिया जा रहा है…',

  // ---- decided ----
  'You are in.': 'आप शामिल हो गए।',
  'Your application has been approved.': 'आपका आवेदन मंज़ूर हो गया है।',
  'You have been approved for {trades}.': 'आपको {trades} के लिए मंज़ूरी मिली है।',
  'Sign out and back in and the app opens on your leads instead of the customer view. There are a few setup steps waiting — the partner agreement, your documents and your bank details. Leads start once those are done.':
      'एक बार साइन आउट करके फिर साइन इन कीजिए — ऐप ग्राहक वाले व्यू की जगह आपकी लीड पर खुलेगा। कुछ सेटअप बाक़ी हैं: पार्टनर एग्रीमेंट, आपके काग़ज़ और बैंक ब्यौरा। ये पूरे होते ही लीड आना शुरू होंगी।',

  'Needs a change': 'कुछ बदलना है',
  'Our team asked for a change.': 'हमारी टीम ने कुछ बदलने को कहा है।',
  'Update this and send it again — it goes back to the same reviewer.':
      'इसे ठीक करके दोबारा भेजिए — यह उन्हीं के पास वापस जाएगा जिन्होंने देखा था।',

  'Not approved': 'मंज़ूर नहीं हुआ',
  'Our team reviewed your application and could not approve it.':
      'हमारी टीम ने आपका आवेदन देखा और उसे मंज़ूर नहीं कर सकी।',
  'You are welcome to apply again once that has changed. Your customer account is unaffected.':
      'जब वह बात बदल जाए, दोबारा आवेदन कीजिए। आपके ग्राहक खाते पर इसका कोई असर नहीं है।',
};
