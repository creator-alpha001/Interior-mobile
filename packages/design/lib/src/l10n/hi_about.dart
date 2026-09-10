/// How it works, and joining as a professional.
///
/// The most carefully-worded file in the set, because these two screens exist
/// to answer objections rather than to label controls, and a translation that
/// hedges answers nothing.
///
/// Three sentences carry the weight:
///
///   **"Money is between you and them."** Decora Shine holds nothing and takes no cut
///   of what a customer pays. A Hindi rendering that blurred this into a vague
///   `भुगतान की सुविधा` would describe a regulated business the platform
///   deliberately is not.
///
///   **"Your phone number is never shared."** The masking rule, stated to the
///   person it protects.
///
///   **"Never charged to be here."** The professional's first question, and the
///   one a listing-fee marketplace would answer differently.
library;

const hiAbout = <String, String>{
  // ---- how it works ----
  'How it works': 'यह कैसे काम करता है',
  'Seven steps, and who holds the money': 'सात क़दम, और पैसा किसके पास रहता है',
  // 'One person who answers' lives in hi_customer.dart — it is the home
  // screen's promise, and this screen reuses it as a heading.
  'Seven steps from a description to a finished job. The only unusual one is that we stay in the middle the whole way.':
      'बताने से लेकर काम पूरा होने तक सात क़दम। इनमें अलग बस यही है कि हम पूरे रास्ते बीच में बने रहते हैं।',

  'You submit one short form': 'आप एक छोटा फ़ॉर्म भरते हैं',
  'What you need, where, in your own words, and when you want to start. If you pick more than one trade, one extra question each: who supplies the material. That is the whole form.':
      'आपको क्या चाहिए, कहाँ, अपने शब्दों में, और कब शुरू करना है। एक से ज़्यादा काम चुनने पर हर एक के लिए एक ही और सवाल: सामान कौन देगा। बस इतना ही फ़ॉर्म है।',
  'We deliberately do not ask for carpet area, paint finish or exact dimensions. At enquiry stage those answers are guesses, and a guess produces a bad quote.':
      'हम जानबूझकर कारपेट एरिया, पेंट की फ़िनिश या सही नाप नहीं पूछते। पूछताछ के समय ये जवाब अंदाज़े होते हैं, और अंदाज़े से ख़राब कोटेशन बनता है।',

  'We call you': 'हम आपको फ़ोन करते हैं',
  'A short call for the detail the form left out — rooms, sizes, finishes, site constraints. It is recorded against your requirement so every professional works from the same brief.':
      'फ़ॉर्म में जो छूट गया उसके लिए एक छोटी बात — कमरे, नाप, फ़िनिश, साइट की अड़चनें। यह आपकी ज़रूरत के साथ दर्ज होता है, ताकि हर कारीगर एक ही ब्यौरे पर काम करे।',

  'Three professionals for each trade': 'हर काम के लिए तीन कारीगर',
  'Our team rings professionals in your city who are approved for that specific trade, checks they are free and interested, and only then assigns them. Nobody is auto-assigned by an algorithm.':
      'हमारी टीम आपके शहर के उन कारीगरों को फ़ोन करती है जो उसी काम के लिए मंज़ूर हैं, देखती है कि वे ख़ाली और इच्छुक हैं, तभी उन्हें काम देती है। कोई मशीन अपने आप किसी को नहीं चुनती।',
  'A requirement covering two trades gets three professionals for each — six in total, working separately.':
      'दो कामों वाली ज़रूरत में हर काम के लिए तीन कारीगर मिलते हैं — कुल छह, अलग-अलग काम करते हुए।',

  'Site visits and written quotes': 'साइट विज़िट और लिखित कोटेशन',
  'We arrange each visit, confirming the slot with you and the professional separately. They measure, then send a written quote with line items, a timeline, a warranty and the material specification.':
      'हर विज़िट हम तय करते हैं, समय आपसे और कारीगर से अलग-अलग पक्का करके। वे नाप लेते हैं, फिर मदवार ब्यौरा, समय-सीमा, वारंटी और सामान की जानकारी के साथ लिखित कोटेशन भेजते हैं।',

  /// The masking rule, said to the person it protects.
  'A professional is given your address for a confirmed visit and nothing else. Your phone number is never shared with them.':
      'कारीगर को आपका पता सिर्फ़ पक्की हुई विज़िट के लिए मिलता है, और कुछ नहीं। आपका फ़ोन नंबर उन्हें कभी नहीं दिया जाता।',

  'Every question goes through us': 'हर सवाल हमारे ज़रिए जाता है',
  'There is no direct line between you and the professionals, in either direction. You ask us; we put it to all three and bring the answers back. One question improves three quotes instead of one, and you are not fielding calls from three people.':
      'आपके और कारीगरों के बीच सीधी बात नहीं होती, किसी भी तरफ़ से। आप हमसे पूछते हैं; हम तीनों तक पहुँचाते हैं और जवाब वापस लाते हैं। एक सवाल से एक नहीं, तीन कोटेशन बेहतर होते हैं — और आपको तीन लोगों के फ़ोन नहीं उठाने पड़ते।',

  'You compare and choose': 'आप मिलाकर देखते हैं और चुनते हैं',
  'One comparison per trade, the same columns for every quote. Choose whoever you want — cheapest, fastest, longest warranty, or the person you simply trusted most on site.':
      'हर काम की एक तुलना, हर कोटेशन के लिए वही ख़ाने। जिसे चाहें चुनिए — सबसे सस्ता, सबसे तेज़, सबसे लंबी वारंटी, या वह जिस पर साइट पर आपको सबसे ज़्यादा भरोसा हुआ।',

  'Agreements, then work': 'एग्रीमेंट, फिर काम',
  'One agreement per professional. If one of them is doing two of your trades that is a single combined contract, not two. Work is then tracked per trade, stage by stage, through to handover.':
      'हर कारीगर के लिए एक एग्रीमेंट। अगर एक ही कारीगर आपके दो काम कर रहा है तो एक ही मिला-जुला एग्रीमेंट बनेगा, दो नहीं। फिर हर काम की प्रगति अलग से, चरण दर चरण, सौंपने तक देखी जाती है।',

  /// The sentence that would do the most damage if it drifted.
  'Money is between you and them': 'पैसा आपके और उनके बीच है',
  'Decora Shine does not hold your money or take a cut of what you pay. You settle directly with your professional, on the terms in the agreement. We are paid a commission by them.':
      'Decora Shine न आपका पैसा रखता है, न आपके भुगतान में से कुछ काटता है। आप सीधे अपने कारीगर से, एग्रीमेंट की शर्तों पर हिसाब करते हैं। हमें कमीशन वे देते हैं।',

  // ---- joining ----
  'Work with us': 'हमारे साथ काम कीजिए',
  'For carpenters, painters and fabricators':
      'बढ़ई, पेंटर और फ़ैब्रिकेटर के लिए',
  'Verified leads for the trades you are approved for. No listing fee — commission only on work you win.':
      'जिन कामों के लिए आप मंज़ूर हैं, उनकी जाँची हुई लीड। कोई लिस्टिंग फ़ीस नहीं — कमीशन सिर्फ़ जीते हुए काम पर।',
  'And what you do not pay': 'और किसका पैसा नहीं लगता',

  /// A professional's first question, and the one a listing-fee marketplace
  /// would answer differently.
  'Never charged to be here': 'यहाँ रहने का कोई पैसा नहीं',
  'No listing fee, no charge to receive a lead. Commission is raised only when a customer signs, at your rate for that trade.':
      'न लिस्टिंग फ़ीस, न लीड लेने का पैसा। कमीशन तभी बनता है जब ग्राहक हस्ताक्षर करता है, उस काम के लिए तय आपकी दर पर।',
  'One brief, one clarification': 'एक ब्यौरा, एक बार की सफ़ाई',
  'You quote against the same written brief as everybody else, and questions come to you through us. No chasing a customer who has stopped answering.':
      'आप वही लिखित ब्यौरा देखकर कोटेशन देते हैं जो बाक़ी सब देखते हैं, और सवाल आप तक हमारे ज़रिए आते हैं। जवाब न देने वाले ग्राहक के पीछे भागना नहीं पड़ता।',
  'Approved trade by trade': 'हर काम की अलग मंज़ूरी',
  'You are approved for each trade separately and rated in each separately, so being excellent at one is not diluted by a job somebody else took.':
      'हर काम के लिए मंज़ूरी अलग मिलती है और रेटिंग भी अलग बनती है, इसलिए एक काम में आपकी महारत किसी और के लिए गए काम से कम नहीं पड़ती।',
  'Two trades, one invoice': 'दो काम, एक बिल',
  'Handle two trades for one customer under a combined agreement and you get one invoice, not two.':
      'एक ही ग्राहक के दो काम मिले-जुले एग्रीमेंट पर करने पर आपको एक बिल मिलता है, दो नहीं।',

  'What we ask for': 'हम क्या माँगते हैं',
  'Before any customer sees you': 'किसी ग्राहक के आपको देखने से पहले',
  'Your registered mobile number, verified.':
      'आपका रजिस्टर्ड मोबाइल नंबर, जाँचा हुआ।',
  'GST registration, where you have one. Not required for smaller workshops.':
      'GST रजिस्ट्रेशन, अगर है तो। छोटी वर्कशॉप के लिए ज़रूरी नहीं।',
  'Recent completed jobs, with locality and approximate date.':
      'हाल के पूरे किए काम, इलाक़े और अंदाज़न तारीख़ के साथ।',
  'Past customers we can call.': 'पुराने ग्राहक, जिनसे हम बात कर सकें।',
  'The cities and localities you actually travel to.':
      'वे शहर और इलाक़े जहाँ आप सचमुच जाते हैं।',

  'How to start': 'शुरू कैसे करें',
  'Tell us about your business and the trades you work in. Our team reads every application and rings you back, usually within two working days. Once you are approved this same app opens on your leads instead of the customer view.':
      'अपने काम और जिन ट्रेड में आप काम करते हैं, उनके बारे में बताइए। हमारी टीम हर आवेदन पढ़ती है और आम तौर पर दो कामकाजी दिन के अंदर फ़ोन करती है। मंज़ूरी मिलने के बाद यही ऐप ग्राहक वाले हिस्से के बजाय आपकी लीड पर खुलेगा।',
  'Apply to join': 'आवेदन करें',
};
