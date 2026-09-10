/// The professional's half: onboarding, leads, quoting, visits and stage proof.
///
/// A different vocabulary from the customer's, and deliberately so. This is
/// trade Hindi as it is actually spoken on a site — नाप, ठेका, किस्त — and the
/// English loanwords that a carpenter in Lucknow uses without thinking are kept
/// rather than replaced: `कोटेशन`, not `मूल्य-प्रस्ताव`; `साइट`, not `कार्यस्थल`.
///
/// Where the two halves share a word they must still say the same thing. A
/// vendor and a customer looking at the same job across a phone call have to be
/// able to agree on what "चरण" means.
library;

const hiVendor = <String, String>{
  // ---- tabs ----
  'Dashboard': 'डैशबोर्ड',
  'Leads': 'लीड',
  'Projects': 'प्रोजेक्ट',
  'Visits': 'विज़िट',
  'More': 'और',

  // ---- the onboarding gate ----
  ///
  /// The gate's job is to say the quiet part out loud. A vendor who does not
  /// know they are excluded assumes the platform simply has no work, and the
  /// Hindi has to be as blunt as the English about that.
  'Before you receive work': 'काम मिलने से पहले',
  'Everything is in place. Leads will start arriving.':
      'सब कुछ तैयार है। लीड आना शुरू हो जाएँगी।',
  'You are not in any lead pool yet. These are the steps between you and the first job.':
      'आप अभी किसी लीड पूल में नहीं हैं। पहले काम तक पहुँचने के लिए ये क़दम बाक़ी हैं।',
  'What is holding things up': 'किस वजह से रुका है',
  '{done} of {total} complete': '{total} में से {done} पूरे',
  '{n} of these must be finished before you are eligible. The rest can wait.':
      'इनमें से {n} पूरे करने ज़रूरी हैं, तभी आप योग्य होंगे। बाक़ी बाद में हो सकते हैं।',
  'Anything still outstanding is optional, and can wait.':
      'जो बचा है वह ज़रूरी नहीं है, बाद में हो सकता है।',
  'Go to my dashboard': 'मेरा डैशबोर्ड खोलें',

  // ---- the partner agreement ----
  'Partner agreement': 'पार्टनर एग्रीमेंट',
  'Acknowledgements': 'स्वीकृतियाँ',
  'Tick each one': 'हर एक पर निशान लगाएँ',
  'Each of these is confirmed separately, and recorded separately.':
      'इनमें से हर एक अलग से स्वीकार की जाती है, और अलग से दर्ज होती है।',
  'Signature': 'हस्ताक्षर',
  'Typed, and stored as typed': 'जैसा लिखा, वैसा ही सहेजा जाएगा',
  'Signatory name': 'हस्ताक्षर करने वाले का नाम',
  'Role': 'पद',
  'Type your full name to sign': 'हस्ताक्षर के लिए अपना पूरा नाम लिखें',
  'Sign and continue': 'हस्ताक्षर करके आगे बढ़ें',
  'Signing records the time, your IP and your device, so the agreement can be evidenced later.':
      'हस्ताक्षर के साथ समय, आपका IP और आपका डिवाइस दर्ज होता है, ताकि बाद में एग्रीमेंट साबित किया जा सके।',

  // ---- dashboard ----
  'One new lead': 'एक नई लीड',
  '{n} new leads': '{n} नई लीड',
  'The first quote in often wins. These are waiting on you.':
      'अक्सर पहला कोटेशन ही जीतता है। ये आपका इंतज़ार कर रही हैं।',
  'Open leads': 'लीड खोलें',
  'Your pipeline': 'आपका काम आगे',
  'Right now': 'अभी',
  'Awaiting your quote': 'आपके कोटेशन का इंतज़ार',
  'Quotes out': 'भेजे गए कोटेशन',
  'Won this period': 'इस अवधि में जीते',
  'Work in hand': 'हाथ में काम',
  'Live': 'चालू',
  'Live projects': 'चालू प्रोजेक्ट',
  'Visits today': 'आज की विज़िट',
  'Unread messages': 'बिना पढ़े संदेश',

  /// Commission is the vendor's own figure and appears on no customer surface.
  /// "Yours alone" carries that, and should not soften into "आपका हिसाब".
  'Commission': 'कमीशन',
  'Yours alone': 'सिर्फ़ आपके लिए',
  'Overdue': 'बकाया',
  'Overdue commission can suspend new lead assignment. Settle it to stay in the pool.':
      'कमीशन बकाया रहने पर नई लीड मिलना रुक सकता है। पूल में बने रहने के लिए इसे चुका दें।',

  // ---- leads ----
  'All': 'सब',
  'Quoting': 'कोटेशन दिया',
  'Won': 'जीते',
  'Lost': 'हारे',
  'Quoted': 'कोटेशन भेजा',
  'Nothing here': 'यहाँ कुछ नहीं',
  'No new leads right now. Assignment is manual — our team rings you before offering one.':
      'अभी कोई नई लीड नहीं। लीड हाथ से दी जाती है — देने से पहले हमारी टीम आपको फ़ोन करती है।',
  'No quotes outstanding.': 'कोई कोटेशन बाक़ी नहीं।',
  'No won jobs in this period yet.': 'इस अवधि में अभी कोई काम नहीं जीता।',
  'Nothing lost. Good.': 'कुछ नहीं हारा। बढ़िया।',
  'No leads have been offered to you yet.': 'आपको अभी कोई लीड नहीं दी गई है।',
  'Ceiling ': 'अधिकतम ',
  'No budget stated': 'बजट नहीं बताया',
  'First to quote': 'कोटेशन देने वाले पहले',
  'Immediate': 'तुरंत',
  'Exploring': 'देख रहे हैं',
  'You supply material': 'सामान आप देंगे',
  'Customer supplies material': 'सामान ग्राहक देगा',
  'Material undecided': 'सामान तय नहीं',
  'Material unknown': 'सामान का पता नहीं',

  // ---- one lead ----
  'Lead': 'लीड',
  'Can you take this on?': 'क्या आप यह काम ले सकते हैं?',
  'Our team offered you this job. Confirming puts you in the running; declining tells the coordinator why.':
      'हमारी टीम ने यह काम आपको दिया है। हाँ कहने पर आप दौड़ में आ जाते हैं; मना करने पर को-ऑर्डिनेटर को वजह पता चल जाती है।',
  'Accept': 'हाँ, लूँगा',
  'Decline': 'मना करें',
  'Why are you declining?': 'आप क्यों मना कर रहे हैं?',
  'Too far, fully booked, not my trade…':
      'बहुत दूर है, काम भरा हुआ है, मेरा काम नहीं…',
  'The brief': 'काम का ब्यौरा',
  'Captured on the call': 'फ़ोन पर लिखा गया',
  'In the customer’s words': 'ग्राहक के अपने शब्दों में',
  'As submitted': 'जैसा भेजा गया',
  'Site notes': 'साइट के नोट',
  'Access and conditions': 'पहुँच और हालात',
  'What they picked': 'उन्होंने क्या चुना',
  'From the catalogue': 'कैटलॉग से',
  'The job': 'काम',
  'Scope and budget': 'दायरा और बजट',
  'Urgency': 'जल्दी',
  'You supply': 'आप देंगे',
  'Customer supplies': 'ग्राहक देगा',
  'Undecided': 'तय नहीं',
  'Budget ceiling': 'बजट की ऊपरी सीमा',
  'Others quoting': 'और कौन कोटेशन दे रहे हैं',
  'Where': 'कहाँ',
  'Locality only, for now': 'फ़िलहाल सिर्फ़ इलाक़ा',

  /// Address release, from the vendor's side. Per service, and only after the
  /// coordinator confirms the visit — the Hindi must not suggest that
  /// accepting the lead is what unlocks it.
  'The full address is released once a site visit for this service is confirmed.':
      'इस काम के लिए साइट विज़िट पक्की होने पर ही पूरा पता दिया जाता है।',
  'Your quote': 'आपका कोटेशन',
  'Send a quote': 'कोटेशन भेजें',
  'Revise your quote': 'अपना कोटेशन बदलें',
  'Messages with Decora Shine': 'Decora Shine के साथ बातचीत',
  'Messages with Decora Shine ({n})': 'Decora Shine के साथ बातचीत ({n})',

  // ---- the quote builder ----
  'New quote': 'नया कोटेशन',
  'Revise quote': 'कोटेशन बदलें',
  'Lines': 'मदें',
  'What you are pricing': 'आप किसका दाम लगा रहे हैं',
  'Add a line': 'मद जोड़ें',
  'Remove this line': 'यह मद हटाएँ',
  'Terms': 'शर्तें',
  'What you are committing to': 'आप किस बात के लिए बँध रहे हैं',
  'Working days': 'काम के दिन',
  'Warranty (months)': 'वारंटी (महीने)',
  'Notes for the coordinator (optional)':
      'को-ऑर्डिनेटर के लिए नोट (ज़रूरी नहीं)',
  'The coordinator reviews this before the customer sees it.':
      'ग्राहक के देखने से पहले को-ऑर्डिनेटर इसे जाँचता है।',
  'Keep the old one': 'पुराना ही रहने दें',
  'Your quote has changed since this screen opened. Close and reopen the lead to see the current one.':
      'यह स्क्रीन खुलने के बाद आपका कोटेशन बदल चुका है। मौजूदा देखने के लिए लीड बंद करके दोबारा खोलें।',

  // ---- visits ----
  'No visits booked': 'कोई विज़िट तय नहीं',
  'The coordinator arranges site visits with both sides and confirms the slot. Nothing to travel to yet.':
      'को-ऑर्डिनेटर दोनों तरफ़ से बात करके साइट विज़िट तय करता है। अभी कहीं जाना नहीं है।',
  'Confirmed': 'पक्की',
  'Awaiting confirmation': 'पक्की होने का इंतज़ार',
  'Rescheduling': 'समय बदला जा रहा है',
  'No show': 'कोई नहीं आया',
  'Consultation': 'सलाह',
  'Site visit': 'साइट विज़िट',
  'Measurement': 'नाप',
  'Handover': 'सौंपना',
  'Visit': 'विज़िट',
  'Address released': 'पता दे दिया गया',
  'Address not released yet': 'पता अभी नहीं दिया गया',
  'Directions': 'रास्ता',
  'Address copied': 'पता कॉपी हो गया',
  'Could not open maps on this device.': 'इस फ़ोन में नक़्शा नहीं खुल पाया।',
  'The full address is released once the coordinator confirms this visit with both sides. It is released per service, so confirming one job does not unlock another.':
      'को-ऑर्डिनेटर दोनों तरफ़ से यह विज़िट पक्की कर दे, तभी पूरा पता दिया जाता है। यह हर काम के लिए अलग से मिलता है, इसलिए एक काम पक्का होने से दूसरे का पता नहीं खुलता।',

  // ---- projects and stage proof ----
  'No live work': 'कोई चालू काम नहीं',
  'A project starts when a customer signs an agreement for a quote you won.':
      'जो कोटेशन आपने जीता, उस पर ग्राहक के हस्ताक्षर होते ही प्रोजेक्ट शुरू हो जाता है।',
  'Submit proof': 'सबूत भेजें',
  'Send new proof': 'नया सबूत भेजें',
  'Sent back for rework': 'दोबारा काम के लिए वापस भेजा',
  'The evidence': 'सबूत',
  'At least one photograph is required. Ops check the work against these before the stage counts.':
      'कम से कम एक तस्वीर ज़रूरी है। चरण गिने जाने से पहले हमारी टीम इन्हीं से काम की जाँच करती है।',
  'What you did': 'आपने क्या किया',
  'For the coordinator': 'को-ऑर्डिनेटर के लिए',
  'Carcass fitted, shutters hung, hardware pending…':
      'ढाँचा लग गया, पल्ले चढ़ गए, हार्डवेयर बाक़ी…',
  'Submit for approval': 'मंज़ूरी के लिए भेजें',

  /// The rule that decides when a customer's progress bar moves. It is
  /// approval, not submission, and the Hindi must not blur the two.
  'Ops check the photographs against the stage. The customer’s progress moves when they approve, not when you submit.':
      'हमारी टीम तस्वीरों को चरण से मिलाकर देखती है। ग्राहक की प्रगति तब बढ़ती है जब वे मंज़ूरी देते हैं — तब नहीं जब आप भेजते हैं।',
  'Uploading…': 'भेजा जा रहा है…',

  /// Vendors watch their data. The arrow and the megabytes carry the
  /// meaning; the only word here is the one saying it went.
  'Sent · {before} → {after}': 'भेज दिया · {before} → {after}',
  'Waiting to send': 'भेजने के इंतज़ार में',
  'Approved': 'मंज़ूर',
  'Awaiting approval': 'मंज़ूरी का इंतज़ार',
  'Sent back': 'वापस भेजा',

  // ---- the coordinator thread ----
  ///
  /// A vendor never talks to the customer. Saying so here is the whole point
  /// of the banner, and it is the sentence a vendor is most likely to test by
  /// trying.
  'You are talking to Decora Shine, not the customer. We carry your questions to them and bring their answers back.':
      'आप Decora Shine से बात कर रहे हैं, ग्राहक से नहीं। आपके सवाल हम उन तक ले जाते हैं और उनके जवाब आप तक लाते हैं।',
  'Ask the coordinator anything about the scope, the site or the timeline.':
      'काम के दायरे, साइट या समय-सीमा के बारे में को-ऑर्डिनेटर से कुछ भी पूछिए।',
  'Message the coordinator': 'को-ऑर्डिनेटर को संदेश भेजें',
  'about {title}': '{title} के बारे में',

  // ---- more ----
  'What you owe the platform': 'आप प्लैटफ़ॉर्म को क्या देना है',
  'Performance': 'प्रदर्शन',
  'Your rating in each trade': 'हर काम में आपकी रेटिंग',
  'Portfolio': 'पोर्टफ़ोलियो',
  'Approved work on your public profile':
      'आपकी सार्वजनिक प्रोफ़ाइल पर मंज़ूर किया गया काम',
  'Nothing owed': 'कुछ बकाया नहीं',
  'Commission is raised when a customer signs an agreement, at your rate for that trade.':
      'ग्राहक के एग्रीमेंट पर हस्ताक्षर करते ही कमीशन बनता है, उस काम के लिए तय आपकी दर पर।',
  'Nothing published': 'कुछ प्रकाशित नहीं',
  'Portfolio work is moderated before it appears on your public profile.':
      'पोर्टफ़ोलियो का काम आपकी सार्वजनिक प्रोफ़ाइल पर आने से पहले जाँचा जाता है।',
  'By trade': 'काम के हिसाब से',
  'Rated separately': 'अलग-अलग रेटिंग',
  'Not yet rated': 'अभी रेटिंग नहीं',
  'Overall': 'कुल मिलाकर',
  'Across every trade': 'सभी कामों में',
  // ---- agreements ----
  'Contracts you have won': 'आपके जीते हुए एग्रीमेंट',
  'One is drawn up when a customer picks your quote.':
      'जब कोई ग्राहक आपका कोटेशन चुनता है, तब एग्रीमेंट बनता है।',

  /// The sentence that stops a vendor invoicing twice for one contract.
  'One contract covering {n} job. Execution still runs per job, and commission is invoiced once.':
      'एक ही एग्रीमेंट, {n} काम के लिए। काम फिर भी अलग-अलग चलता है, और कमीशन का बिल एक ही बार बनता है।',
  'One contract covering {n} jobs. Execution still runs per job, and commission is invoiced once.':
      'एक ही एग्रीमेंट, {n} कामों के लिए। काम फिर भी अलग-अलग चलता है, और कमीशन का बिल एक ही बार बनता है।',

  // ---- the vendor's own record ----
  'Your profile': 'आपकी प्रोफ़ाइल',
  'Approved trades': 'मंज़ूर किए गए काम',
  'What you may be sent': 'आपको क्या भेजा जा सकता है',
  'On record': 'दर्ज ब्यौरा',
  'What customers see': 'ग्राहक क्या देखते हैं',
  'Experience': 'अनुभव',
  'Jobs completed': 'पूरे किए गए काम',
  'Median response': 'जवाब देने का औसत समय',
  '{n} year': '{n} साल',
  '{n} hour': '{n} घंटा',
  '{n} hours': '{n} घंटे',

  /// Said plainly, because a vendor who cannot find the pencil will assume
  /// the app is broken rather than that the feature is absent.
  // ---- strings that never reached context.t(), and so were never asked for
  //      until the scan in l10n_test.dart started looking for them ----

  // performance
  'A good carpenter is not automatically a good painter, so each trade is rated on its own — and leads are ranked by your rating in the trade being browsed.':
      'अच्छा बढ़ई अपने आप अच्छा पेंटर नहीं हो जाता, इसलिए हर काम की रेटिंग अलग बनती है — और लीड उसी काम में आपकी रेटिंग के हिसाब से क्रम में लगती हैं।',
  '{completed} completed · {won} won · {lost} lost · {rate}% win rate':
      '{completed} पूरे · {won} जीते · {lost} हारे · {rate}% जीत दर',
  'Commission {percent}%': 'कमीशन {percent}%',
  'Revenue': 'आमदनी',
  'Median response {n} hour': 'जवाब में आम तौर पर {n} घंटा',
  'Median response {n} hours': 'जवाब में आम तौर पर {n} घंटे',

  // commission
  'Due {date} · {trades}': '{date} तक देना है · {trades}',

  // leads
  '{n} other quoting': '{n} और कोटेशन दे रहा है',
  '{n} others quoting': '{n} और कोटेशन दे रहे हैं',
  '{n} unread': '{n} बिना पढ़े',
  'Quote v{n} out': 'कोटेशन v{n} भेजा जा चुका है',
  '{days} days · {months} months warranty':
      '{days} दिन · {months} महीने की वारंटी',

  /// The masking rule again, on the screen where a vendor is most likely to
  /// go looking for a phone number.
  'Every message goes through Decora Shine. We carry questions to the customer and their answers back to you.':
      'हर संदेश Decora Shine के ज़रिए जाता है। सवाल हम ग्राहक तक ले जाते हैं और उनके जवाब आप तक लाते हैं।',

  // the quote builder's replace dialog
  'Replace quote v{n}?': 'कोटेशन v{n} बदलें?',
  'Your current quote of {amount} will be superseded by this one. The customer sees only the new version.':
      'आपका मौजूदा {amount} का कोटेशन इससे बदल जाएगा। ग्राहक को सिर्फ़ नया कोटेशन दिखता है।',
  'Replace with v{n}': 'v{n} से बदलें',
  'This replaces quote v{n}': 'यह कोटेशन v{n} की जगह लेगा',
  'Currently {amount}. One quote per job is live at a time; sending this supersedes it.':
      'अभी {amount}। एक काम पर एक ही कोटेशन चलता है; यह भेजते ही पुराना ख़त्म हो जाएगा।',
  'Above the customer’s stated ceiling of {amount}.':
      'ग्राहक की बताई {amount} की हद से ऊपर।',
  'Send quote · {amount}': 'कोटेशन भेजें · {amount}',

  // the partner agreement
  'Tick all {n} to continue': 'आगे बढ़ने के लिए सभी {n} पर निशान लगाइए',
  'Effective {date}': '{date} से लागू',

  // projects and stage proof
  '{approved} of {total} stages approved':
      '{total} में से {approved} चरण मंज़ूर',
  '{n} did not send. It is saved on this device and will retry — you will not have to take it again.':
      '{n} नहीं भेजी जा सकी। वह इसी फ़ोन में सुरक्षित है और दोबारा कोशिश होगी — आपको फिर से खींचनी नहीं पड़ेगी।',
  '{n} did not send. They are saved on this device and will retry — you will not have to take them again.':
      '{n} नहीं भेजी जा सकीं। वे इसी फ़ोन में सुरक्षित हैं और दोबारा कोशिश होगी — आपको फिर से खींचनी नहीं पड़ेंगी।',
  'Waiting for {n} photograph to finish sending.':
      '{n} तस्वीर भेजी जा रही है, इंतज़ार कीजिए।',
  'Waiting for {n} photographs to finish sending.':
      '{n} तस्वीरें भेजी जा रही हैं, इंतज़ार कीजिए।',
  // ---- reviews, under the rating they produce ----
  'Left per job, per trade': 'हर काम की, अलग-अलग',
  'A customer leaves one per job, so each trade you deliver is rated on its own.':
      'ग्राहक हर काम के लिए अलग समीक्षा देता है, इसलिए आपके किए हर काम की रेटिंग अपनी होती है।',
  'Quality {quality}/5 · Timeliness {timeliness}/5 · Professionalism {professionalism}/5':
      'काम {quality}/5 · समय {timeliness}/5 · पेशेवर रवैया {professionalism}/5',

  // ---- business details ----
  'Business details': 'कारोबार का ब्यौरा',
  'What we hold on file': 'हमारे रिकॉर्ड में क्या है',
  'Contact': 'संपर्क',
  'GST': 'GST',
  'Not registered': 'रजिस्टर्ड नहीं',
  'Languages': 'भाषाएँ',

  /// Not "not built yet". Editing is not self-service on the web either, and
  /// saying otherwise would describe a mobile shortfall that does not exist.
  'To change any of this, message your coordinator. Your public record is edited by our team, the same way trade approval is — never from an app.':
      'इनमें कुछ भी बदलवाने के लिए अपने को-ऑर्डिनेटर को संदेश भेजिए। आपका सार्वजनिक रिकॉर्ड हमारी टीम बदलती है, ठीक वैसे ही जैसे काम की मंज़ूरी — किसी ऐप से नहीं।',
};
