/// Shared copy: the design-system widgets, the error states both shells use,
/// and the words that recur everywhere.
///
/// The tone rule for this file in particular: these strings appear when
/// something has gone wrong or is taking time, and Hindi has a formal register
/// that reads as an apology from a call centre. That is not the voice. Plain,
/// short, and specific about what happened.
library;

const hiCommon = <String, String>{
  // ---- actions ----
  'Continue': 'आगे बढ़ें',
  'Done': 'हो गया',
  'Try again': 'दोबारा कोशिश करें',
  'Copy': 'कॉपी करें',
  'Cancel': 'रहने दें',
  'Remove': 'हटाएँ',
  'Camera': 'कैमरा',
  'Gallery': 'गैलरी',
  'Description': 'ब्यौरा',
  'Note': 'नोट',
  'Photographs': 'तस्वीरें',
  // The photo viewer's counter.
  '{n} of {total}': '{total} में से {n}',

  // ---- the error states, from async_view ----
  ///
  /// "No connection" is deliberately not "आप ऑफ़लाइन हैं". On a site with one
  /// bar the connection exists and still does not work, and telling somebody
  /// they are offline when they can see their signal reads as a lie.
  'No connection': 'कनेक्शन नहीं मिला',
  'We could not reach Aangan. Check your signal and try again.':
      'हम Aangan तक नहीं पहुँच पाए। अपना सिग्नल देखकर दोबारा कोशिश करें।',

  /// Never "you do not have access". The API answers 404 for somebody else's
  /// record on purpose, and this side genuinely cannot tell the two apart — so
  /// the Hindi must not claim to either.
  'Not found': 'नहीं मिला',
  'We could not find that. It may have been withdrawn.':
      'वह नहीं मिला। हो सकता है उसे वापस ले लिया गया हो।',

  'Too many requests': 'बहुत ज़्यादा अनुरोध',
  'Please wait a moment and try again.': 'थोड़ा रुककर दोबारा कोशिश करें।',
  'Please try again in {n} seconds.': '{n} सेकंड बाद दोबारा कोशिश करें।',
  'That has changed': 'यह बदल चुका है',
  'Someone updated this while you were looking at it. Pull to refresh.':
      'जब आप इसे देख रहे थे तब किसी ने इसे बदल दिया। रिफ़्रेश करने के लिए नीचे खींचें।',
  'Something went wrong': 'कुछ गड़बड़ हो गई',
  'The problem is on our side. Try again in a moment.':
      'दिक़्क़त हमारी तरफ़ है। थोड़ी देर में दोबारा कोशिश करें।',
  'Please try again.': 'दोबारा कोशिश करें।',

  /// The request id. The one thing worth reading out to support, so the word
  /// in front of it has to be one somebody will say on the phone.
  'Reference {id}': 'रेफ़रेंस {id}',

  // ---- status vocabulary ----
  ///
  /// These carry the palette's meaning in words, and the distinction the
  /// palette draws has to survive: `Your turn` is terracotta and means the
  /// reader is the blocker; `With us` is ochre and means they are not.
  'Your turn': 'आपकी बारी',
  'With us': 'हमारे पास',
  'Verified': 'जाँचा हुआ',
  'Signed': 'हस्ताक्षरित',
  'Chosen': 'चुना गया',
  'Not chosen': 'नहीं चुना गया',
  'In progress': 'चल रहा है',
  'Not started': 'शुरू नहीं हुआ',
  'Being checked': 'जाँच हो रही है',
  'More work needed': 'और काम बाक़ी है',
  'Ready': 'तैयार',
  'Required': 'ज़रूरी',
  'Cancelled': 'रद्द',
  'Unknown': 'पता नहीं',
  'Sending': 'भेजा जा रहा है',
  'Sent': 'भेज दिया',
  'Queued': 'क़तार में',
  'Added': 'जुड़ गया',
  'Failed': 'नहीं हो पाया',
  'Could not send': 'भेज नहीं पाए',
  'Not stated': 'नहीं बताया',
  'Not yet': 'अभी नहीं',
  'Optional': 'ज़रूरी नहीं',

  // ---- money and quantity ----
  'Total': 'कुल',
  'Subtotal': 'उप-योग',
  'Qty': 'संख्या',
  'Unit': 'इकाई',
  'Rate': 'दर',
  'Tax': 'टैक्स',
  'Budget': 'बजट',
  'Up to': 'अधिकतम',
  'Whole rupees': 'पूरे रुपये',
};
