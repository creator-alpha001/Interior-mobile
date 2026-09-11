/// The customer's half: home, the requirement flow, quotes, agreements,
/// progress and the message relay.
///
/// Three sentences in this file are load-bearing and are marked where they
/// appear. They describe what the platform actually does — address release,
/// who checks a stage, and who handles money — and a looser Hindi rendering
/// would describe a different product rather than the same one in Hindi.
library;

const hiCustomer = <String, String>{
  // ---- tabs ----
  'Home': 'होम',
  'Explore': 'खोजें',
  'Jobs': 'काम',
  'Messages': 'संदेश',
  'Account': 'खाता',

  // ---- home ----
  'Quotes are ready for your {trade}': 'आपके {trade} के कोटेशन तैयार हैं',
  'Quotes are ready on {n} of your trades': '{n} कामों के कोटेशन तैयार हैं',
  'Compare them and choose a professional. Nothing moves until you do.':
      'उन्हें मिलाकर देखिए और कारीगर चुनिए। जब तक आप नहीं चुनते, कुछ आगे नहीं बढ़ता।',
  'What do you need?': 'आपको क्या चाहिए?',

  /// The promise. "आप जैसे" — like you — rather than "आपकी पसंद के": the
  /// line is about homes that reflect a person, not homes built to an order.
  'Homes that feel like you': 'ऐसे घर जो आप जैसे लगें',
  'Interiors · Furniture · Fabrication · Painting':
      'इंटीरियर · फ़र्नीचर · फ़ैब्रिकेशन · पेंटिंग',
  'Welcome back, {name}': 'फिर से स्वागत है, {name}',
  'Design, furniture and finishes shaped around how you live — by verified local professionals.':
      'डिज़ाइन, फ़र्नीचर और फ़िनिश — आपके रहने के ढंग के हिसाब से, जाँचे हुए स्थानीय कारीगरों के हाथों।',
  'Get free design quotes': 'मुफ़्त डिज़ाइन कोटेशन पाएँ',
  'Explore designs': 'डिज़ाइन देखें',
  'Verified professionals, per trade': 'हर काम के लिए जाँचे हुए कारीगर',
  'Your number is never shared': 'आपका नंबर कभी साझा नहीं होता',
  'One written agreement to handover': 'काम सौंपने तक एक लिखित एग्रीमेंट',
  'A room, a piece or a wall': 'एक कमरा, एक चीज़ या एक दीवार',
  'Start with what you need': 'जो चाहिए, वहीं से शुरू करें',
  'Full catalogue': 'पूरा कैटलॉग',

  // ---- the setup strip ----
  'Add your mobile number and city': 'अपना मोबाइल नंबर और शहर जोड़ें',
  'Add your mobile number': 'अपना मोबाइल नंबर जोड़ें',

  /// Never shared with professionals — the same promise the hero makes, and
  /// the Hindi must not soften it into "rarely" or "only when needed".
  'So our team can call you about your quotes. It is never shared with professionals.':
      'ताकि हमारी टीम आपके कोटेशन के बारे में आपको फ़ोन कर सके। यह कारीगरों के साथ कभी साझा नहीं होता।',
  'So prices and professionals match where you live.':
      'ताकि दाम और कारीगर आपके शहर के हिसाब से हों।',
  'Add mobile number': 'मोबाइल नंबर जोड़ें',
  'Not now': 'अभी नहीं',
  'Tell us what you need': 'बताइए आपको क्या चाहिए',
  'What you get': 'आपको क्या मिलता है',
  'Every job': 'हर काम पर',
  'Verified professionals': 'जाँचे हुए कारीगर',
  'Every one is checked by us before they can quote, and approved trade by trade.':
      'कोटेशन देने से पहले हर कारीगर की जाँच हम करते हैं, और हर काम के लिए अलग से मंज़ूरी देते हैं।',
  'Ratings for the actual trade': 'उसी काम की रेटिंग',
  'A good carpenter is not automatically a good painter, so they are rated separately.':
      'अच्छा बढ़ई अपने आप अच्छा पेंटर नहीं हो जाता, इसलिए हर काम की रेटिंग अलग होती है।',
  'One person who answers': 'एक इंसान जो जवाब देता है',
  'You talk to us, not to four tradespeople. We carry messages both ways.':
      'आप हमसे बात करते हैं, चार कारीगरों से नहीं। बात दोनों तरफ़ हम पहुँचाते हैं।',
  'Stages checked against photographs': 'तस्वीरों से जाँचे गए चरण',

  /// Who checks. "our team has seen evidence" is the promise, and it must not
  /// soften into "जब काम पूरा हो जाए" — the whole point is that somebody
  /// looked.
  'Work counts as done when our team has seen evidence of it — not when somebody says so.':
      'काम तब पूरा गिना जाता है जब हमारी टीम उसका सबूत देख लेती है — तब नहीं जब कोई कह दे।',

  // ---- social proof, and the platform's own figures ----
  'What people say': 'लोग क्या कहते हैं',
  'Finished jobs': 'पूरे हुए काम',
  'Jobs done': 'काम पूरे',
  'Cities': 'शहर',
  'Average': 'औसत',

  // ---- explore ----
  'Professionals': 'कारीगर',
  'Nobody to show yet': 'अभी दिखाने के लिए कोई नहीं',
  'Professionals appear here once our team approves them.':
      'हमारी टीम की मंज़ूरी के बाद कारीगर यहाँ दिखने लगते हैं।',
  '{city} · {n} years': '{city} · {n} साल',
  'No reviews yet': 'अभी कोई रिव्यू नहीं',
  '{rating} ★ · {n} reviews': '{rating} ★ · {n} रिव्यू',
  '{rating} ★ · {n} reviews across all trades':
      '{rating} ★ · सभी कामों में मिलाकर {n} रिव्यू',

  // ---- your jobs ----
  'Your jobs': 'आपके काम',
  'New': 'नया',
  'Nothing yet': 'अभी कुछ नहीं',
  'Tell us what you need and we will find you three verified professionals.':
      'बताइए आपको क्या चाहिए, हम आपके लिए तीन जाँचे हुए कारीगर ढूँढ़ेंगे।',
  'Each job is quoted and scheduled separately, even where the same professional does more than one.':
      'हर काम का कोटेशन और शेड्यूल अलग होता है, चाहे एक ही कारीगर एक से ज़्यादा काम कर रहा हो।',
  'You chose {name}': 'आपने {name} को चुना',
  'You chose a professional': 'आपने एक कारीगर चुना',
  '{n} quote ready to compare': 'मिलाने के लिए {n} कोटेशन तैयार',
  '{n} quotes ready to compare': 'मिलाने के लिए {n} कोटेशन तैयार',
  '{n} professional invited to quote': 'कोटेशन के लिए {n} कारीगर को बुलाया गया',
  '{n} professionals invited to quote':
      'कोटेशन के लिए {n} कारीगरों को बुलाया गया',
  'We are finding professionals for this': 'हम इसके लिए कारीगर ढूँढ़ रहे हैं',

  // ---- comparing quotes ----
  'Compare quotes': 'कोटेशन मिलाइए',
  'No quotes yet. We are still gathering them.':
      'अभी कोई कोटेशन नहीं। हम इकट्ठा कर रहे हैं।',
  '{n} professional has quoted for your {trade}.':
      'आपके {trade} के लिए {n} कारीगर ने कोटेशन दिया है।',
  '{n} professionals have quoted for your {trade}.':
      'आपके {trade} के लिए {n} कारीगरों ने कोटेशन दिए हैं।',
  'Nothing moves until you choose. Take your time — the ratings beside each price are for this trade only.':
      'जब तक आप नहीं चुनते, कुछ आगे नहीं बढ़ेगा। आराम से देखिए — हर दाम के साथ जो रेटिंग है वह सिर्फ़ इसी काम की है।',
  'Our coordinator calls each professional before offering them your job, so quotes arrive over a day or two rather than instantly.':
      'आपका काम देने से पहले हमारा को-ऑर्डिनेटर हर कारीगर से बात करता है, इसलिए कोटेशन तुरंत नहीं, एक-दो दिन में आते हैं।',
  'No ratings in {trade} yet': '{trade} में अभी कोई रेटिंग नहीं',
  '{rating} ★ · {n} review in {trade}': '{rating} ★ · {trade} में {n} रिव्यू',
  '{rating} ★ · {n} reviews in {trade}': '{rating} ★ · {trade} में {n} रिव्यू',
  '{rating} ★ · {n} review overall': '{rating} ★ · कुल {n} रिव्यू',
  '{rating} ★ · {n} reviews overall': '{rating} ★ · कुल {n} रिव्यू',
  'Choose this quote': 'यही कोटेशन चुनें',
  'You chose this one': 'आपने यही चुना',
  'Choose {name}?': '{name} को चुनें?',
  'We will draw up an agreement for {amount} and send it to you to sign. The other quotes for this job close.':
      'हम {amount} का एग्रीमेंट बनाकर आपको हस्ताक्षर के लिए भेजेंगे। इस काम के बाक़ी कोटेशन बंद हो जाएँगे।',
  'Choose them': 'इन्हें चुनें',
  'That quote has been revised since you opened this screen. Pull to refresh to see the current one.':
      'यह स्क्रीन खुलने के बाद वह कोटेशन बदल चुका है। मौजूदा देखने के लिए रिफ़्रेश करें।',

  // ---- the requirement flow ----
  'Step {n} of {total}': 'चरण {n}, कुल {total} में से',
  'Nothing you typed is lost — it is saved on this device. Tap below to try sending it again.':
      'आपने जो लिखा वह कहीं नहीं गया — इसी फ़ोन में सहेजा हुआ है। दोबारा भेजने के लिए नीचे दबाइए।',
  'Verify and send': 'जाँचें और भेजें',
  'Try sending again': 'दोबारा भेजकर देखें',
  'Send my requirement': 'मेरी ज़रूरत भेजें',
  'Skip for now': 'अभी छोड़ें',
  'Pick everything you need. Each becomes its own job, with its own quotes and its own timeline.':
      'जो कुछ चाहिए सब चुन लीजिए। हर एक अपना अलग काम बनेगा, अपने कोटेशन और अपनी समय-सीमा के साथ।',
  'Tell us roughly': 'मोटे तौर पर बताइए',
  'A rough idea is enough. Our coordinator will call and take the detail properly.':
      'मोटा अंदाज़ा काफ़ी है। हमारा को-ऑर्डिनेटर फ़ोन करके पूरी बात लिखेगा।',
  'What needs doing': 'क्या काम करवाना है',
  'Wardrobe for the master bedroom, floor to ceiling…':
      'मास्टर बेडरूम के लिए अलमारी, फ़र्श से छत तक…',
  'Material': 'सामान',
  'Asked per job': 'हर काम के लिए अलग',
  'You can supply your own material for some jobs and not others.':
      'कुछ कामों का सामान आप दे सकते हैं और कुछ का नहीं — यह आपकी मर्ज़ी है।',
  'They supply': 'वे देंगे',
  'I supply': 'मैं दूँगा',
  'Not sure yet': 'अभी तय नहीं',
  'Show us the space': 'जगह दिखाइए',
  'Photographs help a professional quote accurately, and mean fewer visits before work starts. Optional, but worth it.':
      'तस्वीरों से कारीगर सही दाम लगा पाता है, और काम शुरू होने से पहले कम चक्कर लगते हैं। ज़रूरी नहीं, पर फ़ायदेमंद है।',
  'You do not need an account to add these.':
      'ये जोड़ने के लिए खाते की ज़रूरत नहीं है।',
  'Where is it?': 'जगह कहाँ है?',

  /// Address release, stated where it is asked about.
  ///
  /// Per service, and only after a confirmed visit. A Hindi rendering that
  /// blurred this into "we share your address with professionals" would be
  /// describing a different product.
  'Your locality is enough for now. The full address is only shared with a professional once you confirm a visit with them.':
      'अभी सिर्फ़ इलाक़ा काफ़ी है। पूरा पता किसी कारीगर को तभी दिया जाता है जब आप उनके साथ विज़िट पक्की कर लेते हैं।',
  'Locality': 'इलाक़ा',
  'When, and how much?': 'कब, और कितने में?',
  'How soon?': 'कितनी जल्दी?',
  'As soon as possible': 'जितनी जल्दी हो सके',
  'We will prioritise your call': 'हम आपकी बात पहले उठाएँगे',
  'Within a month': 'एक महीने के अंदर',
  'The usual pace': 'सामान्य रफ़्तार',
  'Just exploring': 'बस देख रहे हैं',
  'No rush — get a feel for prices': 'जल्दी नहीं — दाम का अंदाज़ा लगाइए',
  'A ceiling helps professionals judge whether they are right for the job. It is a signal, not a promise, and you are not held to it.':
      'ऊपरी सीमा से कारीगर तय कर पाता है कि यह काम उसके लायक़ है या नहीं। यह एक इशारा है, वादा नहीं — आप इससे बँधे नहीं हैं।',
  'Verify your number': 'अपना नंबर जाँचिए',
  'One last thing. We will text you a code — that is how we reach you about this job, and it sets up your account at the same time.':
      'आख़िरी बात। हम आपको एक कोड भेजेंगे — इसी नंबर पर हम इस काम के बारे में बात करेंगे, और इसी से आपका खाता भी बन जाएगा।',
  'What you are sending': 'आप क्या भेज रहे हैं',

  // ---- messages ----
  'You talk to us, and we talk to the professionals. One conversation per job.':
      'आप हमसे बात करते हैं, और हम कारीगरों से। हर काम पर एक बातचीत।',
  'No conversations yet': 'अभी कोई बातचीत नहीं',
  'A thread opens for each job once you submit it.':
      'काम भेजते ही उसके लिए एक बातचीत खुल जाती है।',
  'about your {trade}': 'आपके {trade} के बारे में',
  'Your coordinator reads this and passes anything relevant to the professionals quoting for you.':
      'आपका को-ऑर्डिनेटर यह पढ़ता है और ज़रूरी बात उन कारीगरों तक पहुँचाता है जो आपके लिए कोटेशन दे रहे हैं।',
  'Ask us anything about your job.': 'अपने काम के बारे में हमसे कुछ भी पूछिए।',
  'Message Decora Shine': 'Decora Shine को संदेश भेजें',
  'You': 'आप',

  // ---- account ----
  'Agreements': 'एग्रीमेंट',
  'Contracts to sign, and signed': 'हस्ताक्षर के लिए, और हो चुके',
  'Progress': 'प्रगति',
  'Work under way': 'चल रहा काम',

  // ---- agreements ----
  'No agreements yet': 'अभी कोई एग्रीमेंट नहीं',
  'Once you choose a quote we draw up the contract and send it here to sign.':
      'कोटेशन चुनते ही हम एग्रीमेंट बनाकर हस्ताक्षर के लिए यहाँ भेज देते हैं।',
  'One contract, {n} jobs. The same professional is doing all of them, so there is a single agreement — but each job runs on its own timeline, and one finishing does not mean the others have.':
      'एक एग्रीमेंट, {n} काम। ये सब एक ही कारीगर कर रहा है, इसलिए एग्रीमेंट एक ही है — पर हर काम की समय-सीमा अलग है, और एक के पूरे होने का मतलब बाक़ी के पूरे होना नहीं।',
  'Sign this agreement': 'इस एग्रीमेंट पर हस्ताक्षर करें',

  /// Payments are off-platform. This is the sentence that would do the most
  /// damage if it drifted, in either language.
  'Signing starts the work and creates your project timeline. Payments are arranged directly with the professional.':
      'हस्ताक्षर करते ही काम शुरू होता है और आपकी समय-सीमा बन जाती है। पैसे का लेन-देन सीधे कारीगर के साथ होता है।',
  'Signed. Your project has started.': 'हस्ताक्षर हो गए। आपका काम शुरू।',
  'Signed. {n} project started.': 'हस्ताक्षर हो गए। {n} काम शुरू।',
  'Signed. {n} projects started.': 'हस्ताक्षर हो गए। {n} काम शुरू।',
  'That did not go through. Nothing was signed — you can try again.':
      'वह नहीं हो पाया। कुछ भी हस्ताक्षरित नहीं हुआ — आप दोबारा कोशिश कर सकते हैं।',
  'We could not confirm whether that went through. Check your connection and pull to refresh before trying again.':
      'हम पक्का नहीं कर पाए कि वह हुआ या नहीं। दोबारा कोशिश करने से पहले कनेक्शन देखिए और रिफ़्रेश कीजिए।',

  // ---- reviews ----
  ///
  /// Per trade, and the Hindi must say so. A rating attaches to this
  /// professional's record in *this* trade and follows them nowhere else —
  /// somebody rating a painter three stars should know it does not touch
  /// their carpentry.
  'Leave a review': 'रिव्यू लिखें',
  'This rates their {trade} only. Ratings on Decora Shine are per trade, so it will not affect their other work.':
      'यह रेटिंग सिर्फ़ इनके {trade} के लिए है। Decora Shine पर रेटिंग हर काम की अलग होती है, इसलिए इससे इनके बाक़ी काम पर कोई असर नहीं पड़ेगा।',
  // 'Overall' is in hi_vendor.dart, on the performance screen. One key has
  //  one home — a duplicate makes the merged const map throw on lookup.
  'The one that counts': 'यही गिना जाता है',
  'And in detail': 'और ब्यौरे से',
  'Quality of the work': 'काम की गुणवत्ता',
  'Kept to the timeline': 'समय का पालन',
  'How they were to deal with': 'बात करने में कैसे रहे',
  'Anything you would tell a friend': 'जो आप किसी दोस्त को बताते',
  'Optional, and read by the next customer':
      'ज़रूरी नहीं, और अगला ग्राहक इसे पढ़ेगा',
  'Post this review': 'रिव्यू भेजें',
  'Reviews appear on their public profile and cannot be edited afterwards.':
      'रिव्यू इनकी सार्वजनिक प्रोफ़ाइल पर दिखता है और बाद में बदला नहीं जा सकता।',
  '{n} star': '{n} स्टार',
  '{n} stars': '{n} स्टार',
  'You rated this {n} ★': 'आपने इसे {n} ★ दिए',

  // ---- visits ----
  ///
  /// A *request*, never a reschedule. The coordinator arranges visits with
  /// both sides; a customer who assumes the old time is cancelled would miss
  /// a professional standing at their door.
  'Move it': 'समय बदलवाएँ',
  'Move requested': 'समय बदलने को कहा है',
  'Ask to move this visit': 'इस विज़िट का समय बदलने को कहें',
  'We will find a slot that works for both of you and confirm it. The current time stands until we do.':
      'हम ऐसा समय ढूँढ़कर पक्का करेंगे जो आप दोनों को ठीक लगे। तब तक मौजूदा समय वैसा ही रहेगा।',
  'When would suit you?': 'आपको कब ठीक रहेगा?',
  'Any morning next week, say': 'जैसे अगले हफ़्ते कोई भी सुबह',
  'Send the request': 'अनुरोध भेजें',
  'Asked. We will come back with a new time.':
      'कह दिया गया। हम नया समय लेकर आएँगे।',

  // ---- progress ----
  'Nothing under way': 'अभी कोई काम नहीं चल रहा',
  'Work starts once you sign an agreement.':
      'एग्रीमेंट पर हस्ताक्षर होते ही काम शुरू होता है।',
  'Our team checks each stage against the professional’s photographs before it counts as done.':
      'हर चरण को पूरा गिनने से पहले हमारी टीम कारीगर की तस्वीरों से उसकी जाँच करती है।',
  // ---- the professionals directory's filters ----
  'Trade': 'काम',
  'All cities': 'सभी शहर',
  'Rated per trade, badged when verified':
      'हर काम की अलग रेटिंग, जाँच के बाद बैज',
  'Most experienced': 'सबसे अनुभवी',
  'Most projects': 'सबसे ज़्यादा काम',
  '{n} professional': '{n} कारीगर',
  '{n} professionals': '{n} कारीगर',

  /// Verification is a badge, not admission. Every professional listed is
  /// approved; "only verified" narrows to the ones whose paperwork is checked.
  'Verification': 'जाँच',
  'All approved professionals': 'सभी मंज़ूर कारीगर',
  'Verified only': 'सिर्फ़ जाँचे हुए',
  'Rating': 'रेटिंग',
  'Any rating': 'कोई भी रेटिंग',
  '{rating} ★ and above': '{rating} ★ और उससे ऊपर',
  'Any experience': 'कोई भी अनुभव',
  '{n}+ years': '{n}+ साल',

  /// Said when a filter emptied the list, not when the pool is empty — the
  /// two need different things from the reader.
  'Nobody matches these filters yet. We source and verify professionals for new areas continuously — tell us what you need anyway.':
      'इन फ़िल्टर से अभी कोई नहीं मिला। नए इलाक़ों के लिए हम लगातार कारीगर ढूँढ़ते और जाँचते रहते हैं — आप फिर भी बताइए कि आपको क्या चाहिए।',
  // ---- strings the unwrapped-literal scan turned up ----
  '{approved} of {total}': '{total} में से {approved}',
  '{n} line': '{n} मद',
  '{n} lines': '{n} मदें',
  'No approved work in this trade yet. Try another, or tell us what you need.':
      'इस काम का कोई मंज़ूर किया गया नमूना अभी नहीं है। कोई और देखिए, या हमें बताइए कि आपको क्या चाहिए।',
  // ---- the home dashboard: the customer's own work, above what we sell ----
  'Your work': 'आपका काम',
  'Still moving': 'जो अभी चल रहा है',

  '{n} agreement ready to sign': '{n} एग्रीमेंट हस्ताक्षर के लिए तैयार',
  '{n} agreements ready to sign': '{n} एग्रीमेंट हस्ताक्षर के लिए तैयार',
  'One per professional, not per job': 'हर कारीगर का एक, हर काम का नहीं',
  '{n} job under way': '{n} काम चल रहा है',
  '{n} jobs under way': '{n} काम चल रहे हैं',
  'Stage by stage, with photographs': 'चरण दर चरण, तस्वीरों के साथ',

  // ---- signed out, on the home screen ----
  'Get quotes': 'कोटेशन मँगाइए',
  // ---- signing in, offered where it is needed rather than at the door ----
  'Sign in': 'साइन इन',

  /// The whole promise of the sign-in model, in one line. There is no
  /// password to forget, which is the objection this answers.
  'Your number is your account. We send a code — there is no password to remember.':
      'आपका नंबर ही आपका खाता है। हम एक कोड भेजते हैं — याद रखने के लिए कोई पासवर्ड नहीं।',

  'Already asked us for something?': 'पहले से हमें कुछ बताया हुआ है?',
  'Sign in with the number you gave us and your jobs, quotes and messages come back.':
      'जो नंबर आपने हमें दिया था, उसी से साइन इन कीजिए — आपके काम, कोटेशन और संदेश वापस आ जाएँगे।',

  'Your jobs live here': 'आपके काम यहाँ रहते हैं',
  'Sign in to see the quotes on your jobs, the visits we have arranged, and where each one has got to.':
      'अपने कामों के कोटेशन, तय की गई विज़िट और हर काम कहाँ तक पहुँचा है — देखने के लिए साइन इन कीजिए।',

  'One conversation per job': 'हर काम की एक बातचीत',
  'You talk to us and we talk to the professionals. Sign in to see your threads.':
      'आप हमसे बात करते हैं, हम कारीगरों से। अपनी बातचीत देखने के लिए साइन इन कीजिए।',

  /// Said next to the sign-in button, because for most people who land here
  /// the other button is the right one — and it is true: the form runs to the
  /// end without an account.
  'No account needed to start — we ask for your number at the end, to send the quotes to.':
      'शुरू करने के लिए खाता ज़रूरी नहीं — नंबर हम आख़िर में पूछते हैं, ताकि कोटेशन भेज सकें।',
  // ---- the quote comparison table ----
  'Price': 'क़ीमत',
  'Time': 'समय',
  'Warranty': 'वारंटी',

  /// The winner in each column, said in a word rather than only in colour —
  /// a comparison nobody can see is not a comparison.
  'Lowest': 'सबसे कम',
  'Fastest': 'सबसे तेज़',
  'Longest': 'सबसे लंबी',

  '{n}d': '{n} दिन',
  '{n} mo': '{n} महीने',
  'Not yet rated here': 'इस काम में अभी रेटिंग नहीं',
  'Sorted by price. All figures include GST.':
      'क़ीमत के हिसाब से क्रम में। सभी आँकड़ों में GST शामिल है।',

  // ---- the trade tiles ----
  '{items} designs · {packages} packages': '{items} डिज़ाइन · {packages} पैकेज',
  // ---- home's summary row, which replaced a copy of the Jobs list ----
  '{n} job': '{n} काम',
  '{n} jobs': '{n} काम',
  'Quotes, visits and messages': 'कोटेशन, विज़िट और संदेश',
  '{n} needs you': '{n} आपके इंतज़ार में',
  '{n} need you': '{n} आपके इंतज़ार में',

  /// The opposite state, and worth naming: nothing is stuck on the reader.
  'All with us': 'सब हमारे पास',
};
