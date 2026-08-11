#!/usr/bin/env python3
"""Generate localized App Store storefront metadata.

The app UI remains English. This generator localizes the App Store copy only,
matching the 50-locale metadata workflow used by the other card apps.

STALE WARNING (2026-08-11): the copy baked into this file still quotes the
pre-raise prices ($1.99 / $9.99 / $29.99) in its subscription paragraphs.
fastlane/metadata/ is now the source of truth and is deliberately price-free:
Guideline 3.1.2 is enforced in the binary, the product page renders the real
per-territory price, and a figure in a description is true in at most one of
175 storefronts once a PPP ladder is applied. Running this as-is would put
wrong prices back into all 50 locales. Strip the price sentences here before
using it again.
"""
from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
METADATA = ROOT / "fastlane" / "metadata"
LOCALES_FILE = ROOT / "scripts" / "asc-supported-locales.json"
PRIVACY_URL = "https://jackwallner.github.io/cribbage/privacy-policy"
TERMS_URL = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"


def profile(
    name: str,
    subtitle: str,
    keywords: str,
    promo: str,
    release: str,
    intro: str,
    rooms: str,
    plus: str,
    subscription: str,
) -> dict[str, str]:
    description = (
        f"{intro}\n\n{rooms}\n\n{plus}\n\n{subscription} "
        f"Terms: {TERMS_URL} Privacy: {PRIVACY_URL}"
    )
    return {
        "name": name,
        "subtitle": subtitle,
        "keywords": keywords,
        "promotional_text": promo,
        "release_notes": release,
        "description": description,
    }


EN_DESCRIPTION = (METADATA / "en-US" / "description.txt").read_text(encoding="utf-8").strip()
EN_RELEASE = (METADATA / "en-US" / "release_notes.txt").read_text(encoding="utf-8").strip()


PROFILES: dict[str, dict[str, str]] = {
    "en": {
        "name": "Cribbage Trainer: Count & Peg",
        "subtitle": "Counting, Pegging & Discards",
        "keywords": "cribbage,practice,scoring,pegging,discard,crib,counting,beginner,lesson,drill,rule,strategy,quiz",
        "promotional_text": "New: Endless Practice deals a fresh hand every time, Fix My Mistakes spaces your review, and Timed Challenge gives you 90 seconds to beat your best.",
        "release_notes": EN_RELEASE,
        "description": EN_DESCRIPTION,
    },
    "es": profile(
        "Cribbage Trainer: Cuenta",
        "Puntos, crib y descartes",
        "cribbage,cartas,puntos,pegging,crib,descarte,contar,principiante,lección,ejercicio,reglas,estrategia,quiz",
        "Nuevo: Endless Practice reparte una mano nueva cada vez. Repasa tus errores y supera tu mejor marca en 90 segundos.",
        "Practica contar, puntuar, descartar y hacer pegging en cuatro salas gratuitas.",
        "Practica el cribbage con una baraja estándar en sesiones de cinco minutos. Aprende el motivo de cada decisión sin oponentes ni presión.",
        "Salas de cartas, puntuación, descarte y pegging. Cuenta manos, elige dos cartas para el crib y practica 15, 31, parejas, escaleras, go y la última carta.",
        "Cribbage+ añade Endless Practice, repaso de errores, un reto de 90 segundos, sets extra y Master Tables. El contenido básico sigue siendo gratuito.",
        "Cribbage+ cuesta $1.99 al mes o $9.99 al año, ambos con una prueba gratuita de una semana, o $29.99 una sola vez con Lifetime. El pago se carga a tu Apple ID y la suscripción se renueva automáticamente salvo cancelación.",
    ),
    "fr": profile(
        "Cribbage Trainer: Compter",
        "Compter, pegging et crib",
        "cribbage,cartes,points,pegging,crib,défausse,compter,débutant,leçon,exercice,règles,stratégie,quiz",
        "Nouveau : Endless Practice distribue une main inédite à chaque fois. Révisez vos erreurs et battez votre record en 90 secondes.",
        "Comptez, marquez, défaussez et pratiquez le pegging dans quatre salles gratuites.",
        "Entraînez-vous au cribbage avec un jeu standard en sessions de cinq minutes. Comprenez chaque décision sans adversaires ni pression.",
        "Salles Cartes, Comptage, Défausse et Pegging. Comptez les mains, choisissez deux cartes pour le crib et pratiquez 15, 31, les paires, suites, go et la dernière carte.",
        "Cribbage+ ajoute Endless Practice, la révision des erreurs, un défi de 90 secondes, des séries supplémentaires et Master Tables. Le contenu de base reste gratuit.",
        "Cribbage+ coûte $1.99 par mois ou $9.99 par an, avec une semaine d'essai gratuit, ou $29.99 une seule fois pour Lifetime. Le paiement passe par votre Apple ID et l'abonnement se renouvelle automatiquement sauf annulation.",
    ),
    "de": profile(
        "Cribbage Trainer: Zählen",
        "Zählen, Pegging und Crib",
        "cribbage,karten,punkte,pegging,crib,ablegen,zählen,anfänger,lektion,übung,regeln,strategie,quiz",
        "Neu: Endless Practice gibt jedes Mal eine frische Hand. Wiederhole Fehler und jage in 90 Sekunden deinen persönlichen Bestwert.",
        "Übe Zählen, Wertung, Ablegen und Pegging in vier kostenlosen Räumen.",
        "Übe Cribbage mit einem Standardkartenspiel in fünfminütigen Einheiten. Verstehe jede Entscheidung ohne Gegner und ohne Druck.",
        "Räume für Karten, Wertung, Ablegen und Pegging. Zähle Hände, lege zwei Karten in das Crib und übe 15, 31, Paare, Reihen, Go und die letzte Karte.",
        "Cribbage+ bietet Endless Practice, Fehler-Wiederholung, eine 90-Sekunden-Challenge, zusätzliche Sets und Master Tables. Die Grundinhalte bleiben kostenlos.",
        "Cribbage+ kostet $1.99 monatlich oder $9.99 jährlich, jeweils mit einer kostenlosen Probephase von einer Woche, oder einmalig $29.99 für Lifetime. Die Zahlung läuft über deine Apple-ID und verlängert sich automatisch, sofern du nicht kündigst.",
    ),
    "it": profile(
        "Cribbage Trainer: Impara",
        "Punti, pegging e scarti",
        "cribbage,carte,punteggio,pegging,crib,scarto,contare,principiante,lezione,esercizio,regole,strategia,quiz",
        "Novità: Endless Practice distribuisce una mano nuova ogni volta. Ripassa gli errori e prova a battere il tuo record in 90 secondi.",
        "Esercitati con conteggio, punteggio, scarti e pegging in quattro stanze gratuite.",
        "Impara il cribbage con un mazzo standard in sessioni da cinque minuti. Capisci ogni decisione senza avversari né pressione.",
        "Stanze Carte, Punteggio, Scarti e Pegging. Conta le mani, scegli due carte per il crib e pratica 15, 31, coppie, sequenze, go e ultima carta.",
        "Cribbage+ aggiunge Endless Practice, ripasso degli errori, una sfida da 90 secondi, set extra e Master Tables. I contenuti base restano gratuiti.",
        "Cribbage+ costa $1.99 al mese o $9.99 all'anno, entrambi con una prova gratuita di una settimana, oppure $29.99 una tantum per Lifetime. Il pagamento usa l'Apple ID e l'abbonamento si rinnova automaticamente salvo annullamento.",
    ),
    "pt": profile(
        "Cribbage Trainer: Aprenda",
        "Pontos, pegging e descarte",
        "cribbage,cartas,pontuação,pegging,crib,descarte,contar,iniciante,aula,exercício,regras,estratégia,quiz",
        "Novidade: Endless Practice distribui uma mão nova sempre. Revise seus erros e tente superar seu melhor resultado em 90 segundos.",
        "Pratique contagem, pontuação, descarte e pegging em quatro salas gratuitas.",
        "Pratique cribbage com um baralho padrão em sessões de cinco minutos. Entenda cada decisão sem adversários nem pressão.",
        "Salas Cartas, Pontuação, Descarte e Pegging. Conte mãos, escolha duas cartas para o crib e pratique 15, 31, pares, sequências, go e a última carta.",
        "Cribbage+ adiciona Endless Practice, revisão dos erros, desafio de 90 segundos, conjuntos extras e Master Tables. O conteúdo básico continua gratuito.",
        "Cribbage+ custa $1.99 por mês ou $9.99 por ano, ambos com uma semana de teste grátis, ou Lifetime por $29.99 em pagamento único. A cobrança usa o Apple ID e a assinatura renova automaticamente salvo cancelamento.",
    ),
    "ja": profile(
        "Cribbage Trainer: クリベッジ",
        "得点計算・ペギング・捨て札",
        "クリベッジ,カード,得点,ペギング,クリブ,捨て札,初心者,練習,ルール,クイズ,戦略,トレーニング",
        "新登場：Endless Practiceは毎回新しい手札を配ります。間違いの復習と90秒のタイムチャレンジも楽しめます。",
        "得点計算、捨て札、ペギングを4つの無料ルームで練習できます。",
        "標準デッキのクリベッジを、1回5分の練習で身につけましょう。対戦相手もプレッシャーも必要ありません。",
        "カード、得点計算、捨て札、ペギングのルームを収録。15、31、ペア、ラン、go、最後のカードを練習できます。",
        "Cribbage+では、Endless Practice、間違いの復習、90秒チャレンジ、追加セット、Master Tablesを利用できます。基本内容は無料です。",
        "Cribbage+は月額$1.99、年額$9.99の自動更新プランで、どちらも1週間無料トライアル付きです。買い切りLifetimeは$29.99です。購入時にApple IDへ請求されます。",
    ),
    "zh-Hans": profile(
        "Cribbage Trainer: 克里比奇",
        "算分、Pegging 与弃牌练习",
        "克里比奇,纸牌,算分,peg,crib,弃牌,计数,新手,教程,练习,规则,策略,测验",
        "全新：Endless Practice每次都发一手新牌。复习错题，并在90秒限时挑战中刷新最佳成绩。",
        "在四个免费房间练习克里比奇的算分、弃牌和Pegging。",
        "用每次五分钟的练习掌握标准牌组克里比奇。计算手牌，理解弃牌选择，并学习每个答案的原因。",
        "卡牌、算分、弃牌和Pegging房间。练习15、31、对子、顺子、go和最后一张牌。",
        "Cribbage+增加Endless Practice、错题复习、90秒挑战、额外练习集和Master Tables。基础内容保持免费。",
        "Cribbage+提供每月$1.99、每年$9.99的自动续订订阅，均含一周免费试用，也提供一次性买断Lifetime $29.99。确认购买后费用从Apple ID扣除。",
    ),
    "zh-Hant": profile(
        "Cribbage Trainer: 克里比奇",
        "算分、Pegging 與棄牌練習",
        "克里比奇,撲克牌,算分,peg,crib,棄牌,計數,新手,教學,練習,規則,策略,測驗",
        "全新：Endless Practice每次都發一手新牌。複習錯題，並在90秒限時挑戰中刷新最佳成績。",
        "在四個免費房間練習克里比奇的算分、棄牌和Pegging。",
        "用每次五分鐘的練習掌握標準牌組克里比奇。計算手牌，理解棄牌選擇，並學習每個答案的原因。",
        "卡牌、算分、棄牌和Pegging房間。練習15、31、對子、順子、go和最後一張牌。",
        "Cribbage+增加Endless Practice、錯題複習、90秒挑戰、額外練習集和Master Tables。基礎內容保持免費。",
        "Cribbage+提供每月$1.99、每年$9.99的自動續訂訂閱，均含一週免費試用，也提供一次性買斷Lifetime $29.99。確認購買後費用從Apple ID扣除。",
    ),
    "ko": profile(
        "Cribbage Trainer: 크리비지",
        "점수, 페깅과 버리기 연습",
        "크리비지,카드,점수,페깅,크립,버리기,계산,초보자,레슨,연습,규칙,전략,퀴즈",
        "신규: Endless Practice는 매번 새로운 핸드를 나눠 줍니다. 틀린 문제를 복습하고 90초 기록에 도전하세요.",
        "네 개의 무료 방에서 점수 계산, 버리기와 페깅을 연습하세요.",
        "표준 카드 덱 크리비지를 5분 연습으로 익혀 보세요. 상대도 부담도 계정도 필요 없습니다.",
        "카드, 점수 계산, 버리기와 페깅 방을 제공합니다. 15, 31, 페어, 런, go와 마지막 카드를 연습합니다.",
        "Cribbage+는 Endless Practice, 오답 복습, 90초 도전, 추가 세트와 Master Tables를 제공합니다. 기본 내용은 무료입니다.",
        "Cribbage+는 월 $1.99, 연 $9.99의 자동 갱신 구독을 제공하며 1주 무료 체험이 포함됩니다. 일회성 Lifetime 구매는 $29.99입니다. 결제는 Apple ID로 진행됩니다.",
    ),
    "ar": profile(
        "Cribbage Trainer: كريبج",
        "تدريب الحساب والبيغ والرمي",
        "كريبج,بطاقات,نقاط,بيغ,كريب,رمي,حساب,مبتدئ,درس,تدريب,قواعد,استراتيجية,اختبار",
        "جديد: توزع Endless Practice يدًا جديدة كل مرة. راجع أخطاءك وتحد أفضل نتيجة لك في 90 ثانية.",
        "تدرب على الحساب والرمي والبيغ في أربع غرف مجانية.",
        "تدرب على الكريبج باستخدام مجموعة أوراق قياسية في جلسات مدتها خمس دقائق، من دون خصوم أو ضغط.",
        "غرف للبطاقات والحساب والرمي والبيغ. تدرب على 15 و31 والأزواج والسلاسل وgo والورقة الأخيرة.",
        "يضيف Cribbage+ التدريب اللانهائي، ومراجعة الأخطاء، وتحدي 90 ثانية، ومجموعات إضافية وMaster Tables. المحتوى الأساسي مجاني.",
        "يتوفر Cribbage+ باشتراك شهري $1.99 أو سنوي $9.99، وكلاهما يتضمن تجربة مجانية لمدة أسبوع، أو شراء Lifetime لمرة واحدة بقيمة $29.99. يتم الخصم من Apple ID ويتجدد الاشتراك تلقائيًا.",
    ),
    "he": profile(
        "Cribbage Trainer: קריבג׳",
        "חישוב, פגינג וזריקות",
        "קריבג׳,קלפים,ניקוד,פגינג,קריב,זריקה,חישוב,מתחילים,שיעור,תרגול,חוקים,אסטרטגיה,חידון",
        "חדש: Endless Practice מחלק יד חדשה בכל פעם. חזרו על טעויות ואתגרו את השיא האישי שלכם ב-90 שניות.",
        "תרגלו חישוב, זריקות ופגינג בארבעה חדרים חינמיים.",
        "תרגלו קריבג׳ עם חפיסה רגילה במפגשים של חמש דקות. בלי יריבים, בלי לחץ ובלי חשבון.",
        "חדרי קלפים, ניקוד, זריקות ופגינג. תרגלו 15, 31, זוגות, רצפים, go והקלף האחרון.",
        "Cribbage+ מוסיף Endless Practice, חזרה על טעויות, אתגר 90 שניות, סטים נוספים ו-Master Tables. התוכן הבסיסי חינמי.",
        "Cribbage+ זמין במנוי חודשי ב-$1.99 או שנתי ב-$9.99, שניהם כוללים ניסיון חינם של שבוע, או ברכישת Lifetime חד-פעמית ב-$29.99. החיוב מתבצע דרך Apple ID והמנוי מתחדש אוטומטית.",
    ),
    "nl": profile(
        "Cribbage Trainer: Oefen",
        "Tellen, pegging en crib",
        "cribbage,kaarten,punten,pegging,crib,afleggen,tellen,beginner,les,oefening,regels,strategie,quiz",
        "Nieuw: Endless Practice deelt steeds een nieuwe hand. Herhaal fouten en verbeter je record in de uitdaging van 90 seconden.",
        "Oefen tellen, scoren, afleggen en pegging in vier gratis kamers.",
        "Oefen cribbage met een standaard kaartspel in sessies van vijf minuten. Geen tegenstanders, druk of account nodig.",
        "Kamers voor kaarten, score, afleggen en pegging. Oefen 15, 31, paren, reeksen, go en de laatste kaart.",
        "Cribbage+ voegt Endless Practice, foutenanalyse, een uitdaging van 90 seconden, extra sets en Master Tables toe. De basis blijft gratis.",
        "Cribbage+ kost $1.99 per maand of $9.99 per jaar, beide met een gratis proefweek, of $29.99 eenmalig voor Lifetime. Betaling loopt via Apple ID en verlengt automatisch tenzij je opzegt.",
    ),
    "pl": profile(
        "Cribbage Trainer: Ćwicz",
        "Liczenie, pegging i odrzuty",
        "cribbage,karty,punkty,pegging,crib,odrzut,liczenie,początkujący,lekcja,ćwiczenie,zasady,strategia,quiz",
        "Nowość: Endless Practice rozdaje za każdym razem nową rękę. Powtarzaj błędy i pobij wynik w wyzwaniu 90 sekund.",
        "Ćwicz liczenie, punktację, odrzuty i pegging w czterech darmowych pokojach.",
        "Ćwicz cribbage ze standardową talią w pięciominutowych sesjach. Bez przeciwników, presji i konta.",
        "Pokoje Kart, Punktacji, Odrzutów i Peggingu. Ćwicz 15, 31, pary, sekwencje, go i ostatnią kartę.",
        "Cribbage+ dodaje Endless Practice, powtórkę błędów, wyzwanie 90 sekund, dodatkowe zestawy i Master Tables. Podstawy są darmowe.",
        "Cribbage+ kosztuje $1.99 miesięcznie lub $9.99 rocznie, oba plany obejmują tydzień próby, albo $29.99 jednorazowo za Lifetime. Płatność pobiera Apple ID, a subskrypcja odnawia się automatycznie.",
    ),
    "ru": profile(
        "Cribbage Trainer: Практика",
        "Подсчёт, пеггинг и сброс",
        "криббедж,карты,очки,пеггинг,криб,сброс,подсчёт,новичок,урок,тренировка,правила,стратегия,викторина",
        "Новинка: Endless Practice каждый раз раздаёт новую руку. Повторяйте ошибки и побейте свой результат в испытании на 90 секунд.",
        "Тренируйте подсчёт, очки, сброс и пеггинг в четырёх бесплатных комнатах.",
        "Тренируйте криббедж со стандартной колодой в пятиминутных сессиях. Без соперников, давления и аккаунта.",
        "Комнаты Карт, Подсчёта, Сброса и Пеггинга. Тренируйте 15, 31, пары, серии, go и последнюю карту.",
        "Cribbage+ добавляет Endless Practice, повторение ошибок, испытание на 90 секунд, дополнительные наборы и Master Tables. Основы остаются бесплатными.",
        "Cribbage+ стоит $1.99 в месяц или $9.99 в год, оба плана включают бесплатную неделю, либо Lifetime за $29.99 единоразово. Платёж списывается с Apple ID, а подписка продлевается автоматически.",
    ),
    "tr": profile(
        "Cribbage Trainer: Öğren",
        "Puan, pegging ve kart atma",
        "cribbage,iskambil,puan,pegging,crib,kartatma,sayma,başlangıç,ders,alıştırma,kurallar,strateji,quiz",
        "Yeni: Endless Practice her seferinde yeni bir el dağıtır. Hatalarını tekrar et ve 90 saniyede rekorunu geliştir.",
        "Dört ücretsiz odada sayma, puanlama, kart atma ve pegging çalış.",
        "Standart desteyle cribbage oyununu beş dakikalık çalışmalarla öğren. Rakip, baskı veya hesap gerekmez.",
        "Kart, puanlama, kart atma ve pegging odalarında 15, 31, çift, seri, go ve son kartı çalış.",
        "Cribbage+ Endless Practice, hata tekrarı, 90 saniyelik meydan okuma, ek setler ve Master Tables ekler. Temel içerik ücretsizdir.",
        "Cribbage+ aylık $1.99 veya yıllık $9.99, ikisi de bir haftalık ücretsiz denemeyle, ya da tek seferlik $29.99 Lifetime satın alımıyla sunulur. Ödeme Apple ID'den alınır ve abonelik otomatik yenilenir.",
    ),
    "vi": profile(
        "Cribbage Trainer: Luyện tập",
        "Tính điểm, pegging và bỏ bài",
        "cribbage,bài tây,điểm,pegging,crib,bỏ bài,đếm,người mới,bài học,luyện tập,luật,chiến thuật,đố vui",
        "Mới: Endless Practice chia một tay bài mới mỗi lần. Ôn lỗi sai và chinh phục thành tích trong thử thách 90 giây.",
        "Luyện đếm điểm, bỏ bài và pegging trong bốn phòng miễn phí.",
        "Luyện cribbage với bộ bài tiêu chuẩn trong các phiên năm phút. Không cần đối thủ, áp lực hay tài khoản.",
        "Các phòng Lá bài, Tính điểm, Bỏ bài và Pegging. Luyện 15, 31, đôi, chuỗi, go và lá cuối.",
        "Cribbage+ thêm Endless Practice, ôn lỗi sai, thử thách 90 giây, bộ bài bổ sung và Master Tables. Nội dung cơ bản vẫn miễn phí.",
        "Cribbage+ có giá $1.99 mỗi tháng hoặc $9.99 mỗi năm, đều có một tuần dùng thử miễn phí, hoặc Lifetime một lần $29.99. Phí tính vào Apple ID và gói tự gia hạn.",
    ),
    "id": profile(
        "Cribbage Trainer: Berlatih",
        "Hitung poin, pegging & buang",
        "cribbage,kartu,poin,pegging,crib,buang,hitung,pemula,pelajaran,latihan,aturan,strategi,kuis",
        "Baru: Endless Practice membagikan tangan baru setiap kali. Ulangi kesalahan dan kejar rekor terbaik dalam tantangan 90 detik.",
        "Latih penghitungan, skor, buang kartu, dan pegging di empat ruang gratis.",
        "Latih cribbage dengan dek standar dalam sesi lima menit. Tanpa lawan, tekanan, atau akun.",
        "Ruang Kartu, Skor, Buang Kartu, dan Pegging. Latih 15, 31, pasangan, run, go, dan kartu terakhir.",
        "Cribbage+ menambahkan Endless Practice, ulasan kesalahan, tantangan 90 detik, set ekstra, dan Master Tables. Dasarnya tetap gratis.",
        "Cribbage+ tersedia seharga $1.99 per bulan atau $9.99 per tahun, keduanya dengan uji coba gratis satu minggu, atau Lifetime $29.99 sekali bayar. Pembayaran memakai Apple ID dan langganan diperpanjang otomatis.",
    ),
    "ms": profile(
        "Cribbage Trainer: Berlatih",
        "Kira mata, pegging dan buang",
        "cribbage,kad,mata,pegging,crib,buang,kira,pemula,pelajaran,latihan,peraturan,strategi,kuiz",
        "Baharu: Endless Practice mengagihkan tangan baharu setiap kali. Ulang kesilapan dan kejar rekod terbaik dalam cabaran 90 saat.",
        "Berlatih mengira, menjaringkan mata, membuang kad dan pegging dalam empat bilik percuma.",
        "Berlatih cribbage dengan dek standard dalam sesi lima minit. Tiada lawan, tekanan atau akaun diperlukan.",
        "Bilik Kad, Mata, Buang Kad dan Pegging. Berlatih 15, 31, pasangan, run, go dan kad terakhir.",
        "Cribbage+ menambah Endless Practice, ulang kaji kesilapan, cabaran 90 saat, set tambahan dan Master Tables. Asas kekal percuma.",
        "Cribbage+ berharga $1.99 sebulan atau $9.99 setahun, kedua-duanya termasuk percubaan percuma seminggu, atau Lifetime $29.99 sekali bayar. Bayaran dicaj kepada Apple ID dan langganan diperbaharui secara automatik.",
    ),
    "th": profile(
        "Cribbage Trainer: ฝึกเล่น",
        "นับแต้ม เพ็กกิง และทิ้งไพ่",
        "คริบเบจ,ไพ่,แต้ม,เพ็กกิง,คริบ,ทิ้งไพ่,นับแต้ม,มือใหม่,บทเรียน,ฝึกฝน,กฎ,กลยุทธ์,ควิซ",
        "ใหม่: Endless Practice แจกมือใหม่ทุกครั้ง ทบทวนข้อผิดพลาดและท้าสถิติที่ดีที่สุดในภารกิจ 90 วินาที",
        "ฝึกนับแต้ม การทิ้งไพ่ และเพ็กกิงในห้องฝึกฟรีสี่ห้อง",
        "ฝึกเล่นคริบเบจด้วยสำรับมาตรฐานในเซสชันละห้านาที ไม่ต้องมีคู่แข่ง ความกดดัน หรือบัญชี",
        "ห้องไพ่ การนับแต้ม การทิ้งไพ่ และเพ็กกิง ฝึก 15, 31, คู่, เรียง, go และไพ่ใบสุดท้าย",
        "Cribbage+ เพิ่ม Endless Practice การทบทวนข้อผิดพลาด ภารกิจ 90 วินาที ชุดฝึกเพิ่มเติม และ Master Tables เนื้อหาพื้นฐานยังฟรี",
        "Cribbage+ ราคา $1.99 ต่อเดือน หรือ $9.99 ต่อปี ทั้งสองแบบมีทดลองใช้ฟรีหนึ่งสัปดาห์ หรือซื้อ Lifetime ครั้งเดียว $29.99 ระบบเรียกเก็บเงินจาก Apple ID และต่ออายุอัตโนมัติ",
    ),
    "ca": profile(
        "Cribbage Trainer: Aprèn",
        "Comptar, pegging i descart",
        "cribbage,cartes,punts,pegging,crib,descart,comptar,principiant,llicó,exercici,regles,estratègia,quiz",
        "Novetat: Endless Practice reparteix una mà nova cada vegada. Repasa els errors i supera el teu rècord en 90 segons.",
        "Practica el recompte, la puntuació, el descart i el pegging en quatre sales gratuïtes.",
        "Practica el cribbage amb una baralla estàndard en sessions de cinc minuts. Sense rivals, pressió ni compte.",
        "Sales de cartes, puntuació, descart i pegging. Practica 15, 31, parelles, seqüències, go i l'última carta.",
        "Cribbage+ afegeix Endless Practice, repàs d'errors, un repte de 90 segons, conjunts addicionals i Master Tables. Les bases són gratuïtes.",
        "Cribbage+ costa $1.99 al mes o $9.99 a l'any, amb una setmana de prova gratuïta, o Lifetime per $29.99 en un únic pagament. El pagament usa l'Apple ID i es renova automàticament.",
    ),
    "cs": profile(
        "Cribbage Trainer: Trénink",
        "Počítání, pegging a odhozy",
        "cribbage,karty,body,pegging,crib,odhoz,počítání,začátečník,lekce,cvičení,pravidla,strategie,kviz",
        "Novinka: Endless Practice rozdává pokaždé novou ruku. Opakuj chyby a překonej svůj rekord ve výzvě na 90 sekund.",
        "Trénuj počítání, skóre, odhozy a pegging ve čtyřech bezplatných místnostech.",
        "Procvičuj cribbage se standardním balíčkem v pětiminutových lekcích. Bez soupeřů, tlaku a účtu.",
        "Místnosti Karty, Skóre, Odhozy a Pegging. Procvičuj 15, 31, páry, postupky, go a poslední kartu.",
        "Cribbage+ přidává Endless Practice, opakování chyb, výzvu na 90 sekund, další sady a Master Tables. Základ zůstává zdarma.",
        "Cribbage+ stojí $1.99 měsíčně nebo $9.99 ročně, oba plány mají týdenní zkušební období, případně Lifetime za $29.99 jednorázově. Platba jde přes Apple ID a předplatné se obnovuje automaticky.",
    ),
    "da": profile(
        "Cribbage Trainer: Træn",
        "Tæl, pegging og crib",
        "cribbage,kort,point,pegging,crib,aflægning,tæl,begynder,lektion,øvelse,regler,strategi,quiz",
        "Nyhed: Endless Practice giver en ny hånd hver gang. Gentag fejl og jag din rekord i udfordringen på 90 sekunder.",
        "Øv tælling, point, aflægning og pegging i fire gratis rum.",
        "Øv cribbage med et standardspil i sessioner på fem minutter. Ingen modstandere, pres eller konto.",
        "Rum til kort, point, aflægning og pegging. Øv 15, 31, par, serier, go og det sidste kort.",
        "Cribbage+ tilføjer Endless Practice, fejlgentagelse, en udfordring på 90 sekunder, ekstra sæt og Master Tables. Grundindholdet er gratis.",
        "Cribbage+ koster $1.99 om måneden eller $9.99 om året, begge med en gratis prøveuge, eller Lifetime for $29.99 som engangskøb. Betaling sker via Apple ID og fornyes automatisk.",
    ),
    "el": profile(
        "Cribbage Trainer: Εξάσκηση",
        "Μέτρημα, pegging και crib",
        "cribbage,κάρτες,πόντοι,pegging,crib,απόρριψη,μέτρημα,αρχάριοι,μάθημα,εξάσκηση,κανόνες,στρατηγική,κουίζ",
        "Νέο: το Endless Practice μοιράζει νέο χέρι κάθε φορά. Επανάλαβε λάθη και κυνήγησε το ρεκόρ σου σε 90 δευτερόλεπτα.",
        "Εξάσκησε μέτρημα, σκορ, απόρριψη και pegging σε τέσσερις δωρεάν χώρους.",
        "Μάθε cribbage με τυπική τράπουλα σε συνεδρίες πέντε λεπτών. Χωρίς αντιπάλους, πίεση ή λογαριασμό.",
        "Χώροι για κάρτες, σκορ, απόρριψη και pegging. Εξάσκησε 15, 31, ζευγάρια, σειρές, go και το τελευταίο φύλλο.",
        "Το Cribbage+ προσθέτει Endless Practice, επανάληψη λαθών, πρόκληση 90 δευτερολέπτων, επιπλέον σετ και Master Tables. Τα βασικά παραμένουν δωρεάν.",
        "Το Cribbage+ κοστίζει $1.99 τον μήνα ή $9.99 τον χρόνο, με δωρεάν δοκιμή μίας εβδομάδας, ή Lifetime $29.99 εφάπαξ. Η χρέωση γίνεται στο Apple ID και η συνδρομή ανανεώνεται αυτόματα.",
    ),
    "fi": profile(
        "Cribbage Trainer: Harjoittele",
        "Laske, pegging ja crib",
        "cribbage,kortit,pisteet,pegging,crib,poisheitto,laskenta,aloittelija,oppitunti,harjoitus,säännöt,strategia,visa",
        "Uutta: Endless Practice jakaa joka kerta uuden käden. Kertaa virheet ja tavoittele ennätystäsi 90 sekunnin haasteessa.",
        "Harjoittele laskemista, pisteitä, poisheittoa ja peggingiä neljässä ilmaisessa huoneessa.",
        "Harjoittele cribbagea tavallisella pakalla viiden minuutin jaksoissa. Ei vastustajia, painetta tai tiliä.",
        "Kortti-, piste-, poisheitto- ja pegging-huoneet. Harjoittele 15:tä, 31:tä, pareja, sarjoja, go:ta ja viimeistä korttia.",
        "Cribbage+ lisää Endless Practicen, virheiden kertauksen, 90 sekunnin haasteen, lisäsarjat ja Master Tablesin. Perus sisältö on maksutonta.",
        "Cribbage+ maksaa $1.99 kuukaudessa tai $9.99 vuodessa, molemmissa on viikon ilmainen kokeilu, tai Lifetime $29.99 kertamaksuna. Maksu veloitetaan Apple ID:ltä ja tilaus uusiutuu automaattisesti.",
    ),
    "hr": profile(
        "Cribbage Trainer: Vježbaj",
        "Brojanje, pegging i odbačaj",
        "cribbage,karte,bodovi,pegging,crib,odbacivanje,brojanje,početnik,lekcija,vježba,pravila,strategija,kviz",
        "Novo: Endless Practice svaki put dijeli novu ruku. Ponavljaj pogreške i popravi rekord u izazovu od 90 sekundi.",
        "Vježbaj brojanje, bodove, odbacivanje i pegging u četiri besplatne sobe.",
        "Vježbaj cribbage sa standardnim špilom u sesijama od pet minuta. Bez protivnika, pritiska ili računa.",
        "Sobe za karte, bodovanje, odbacivanje i pegging. Vježbaj 15, 31, parove, nizove, go i zadnju kartu.",
        "Cribbage+ dodaje Endless Practice, ponavljanje pogrešaka, izazov od 90 sekundi, dodatne setove i Master Tables. Osnove ostaju besplatne.",
        "Cribbage+ košta $1.99 mjesečno ili $9.99 godišnje, uz besplatni tjedan probe, ili Lifetime $29.99 jednokratno. Plaćanje ide preko Apple ID-ja, a pretplata se automatski obnavlja.",
    ),
    "hu": profile(
        "Cribbage Trainer: Gyakorlás",
        "Számolás, pegging és dobás",
        "cribbage,kártya,pont,pegging,crib,dobás,számolás,kezdő,lecke,gyakorlás,szabály,stratégia,kvíz",
        "Újdonság: az Endless Practice minden alkalommal új leosztást ad. Ismételd a hibákat, és döntsd meg a 90 másodperces rekordodat.",
        "Gyakorold a számolást, pontozást, dobást és pegginget négy ingyenes szobában.",
        "Tanuld a cribbage-et szabványos paklival, ötperces gyakorlásokban. Nincs ellenfél, nyomás vagy fiók.",
        "Kártya-, pontozás-, dobás- és pegging-szobák. Gyakorold a 15-öt, 31-et, párokat, sorokat, go-t és az utolsó lapot.",
        "A Cribbage+ Endless Practice-t, hibaismétlést, 90 másodperces kihívást, extra készleteket és Master Tables-t ad. Az alap ingyenes.",
        "A Cribbage+ havi $1.99 vagy évi $9.99, mindkettő egyhetes ingyenes próbával, vagy Lifetime $29.99 egyszeri vásárlás. A fizetés Apple ID-n történik, az előfizetés automatikusan megújul.",
    ),
    "no": profile(
        "Cribbage Trainer: Øv",
        "Tell, pegging og crib",
        "cribbage,kort,poeng,pegging,crib,kaste,telling,nybegynner,leksjon,øvelse,regler,strategi,quiz",
        "Nytt: Endless Practice deler en ny hånd hver gang. Gjenta feil og jag rekorden din i 90-sekundersutfordringen.",
        "Øv på telling, poeng, kasting og pegging i fire gratis rom.",
        "Øv cribbage med en standard kortstokk i femminuttersøkter. Ingen motstandere, press eller konto.",
        "Rom for kort, poeng, kasting og pegging. Øv på 15, 31, par, rekker, go og siste kort.",
        "Cribbage+ gir Endless Practice, repetisjon av feil, en 90-sekundersutfordring, ekstra sett og Master Tables. Grunninnholdet er gratis.",
        "Cribbage+ koster $1.99 per måned eller $9.99 per år, begge med en gratis prøveuke, eller Lifetime for $29.99 som engangskjøp. Betaling skjer med Apple ID og fornyes automatisk.",
    ),
    "ro": profile(
        "Cribbage Trainer: Exersează",
        "Numărare, pegging și aruncări",
        "cribbage,cărți,puncte,pegging,crib,aruncare,numărare,începător,lecție,exercițiu,reguli,strategie,quiz",
        "Nou: Endless Practice împarte o mână nouă de fiecare dată. Repetă greșelile și bate-ți recordul în provocarea de 90 de secunde.",
        "Exersează numărarea, punctajul, aruncarea și pegging în patru camere gratuite.",
        "Învață cribbage cu un pachet standard în sesiuni de cinci minute. Fără adversari, presiune sau cont.",
        "Camere pentru cărți, punctaj, aruncare și pegging. Exersează 15, 31, perechi, serii, go și ultima carte.",
        "Cribbage+ adaugă Endless Practice, repetarea greșelilor, provocarea de 90 de secunde, seturi suplimentare și Master Tables. Baza rămâne gratuită.",
        "Cribbage+ costă $1.99 lunar sau $9.99 anual, cu o săptămână de probă gratuită, ori Lifetime $29.99 o singură dată. Plata se face prin Apple ID, iar abonamentul se reînnoiește automat.",
    ),
    "sk": profile(
        "Cribbage Trainer: Tréning",
        "Počítanie, pegging a odhody",
        "cribbage,karty,body,pegging,crib,odhod,počítanie,začiatočník,lekcia,cvičenie,pravidlá,stratégia,kvíz",
        "Novinka: Endless Practice rozdá zakaždým novú ruku. Opakuj chyby a prekonaj svoj rekord vo výzve na 90 sekúnd.",
        "Trénuj počítanie, skóre, odhody a pegging v štyroch bezplatných miestnostiach.",
        "Cvič cribbage so štandardným balíčkom v päťminútových lekciách. Bez súperov, tlaku a účtu.",
        "Miestnosti Karty, Skóre, Odhody a Pegging. Cvič 15, 31, páry, postupky, go a poslednú kartu.",
        "Cribbage+ pridáva Endless Practice, opakovanie chýb, 90-sekundovú výzvu, ďalšie súpravy a Master Tables. Základ zostáva zadarmo.",
        "Cribbage+ stojí $1.99 mesačne alebo $9.99 ročne, oba plány majú týždeň bezplatnej skúšky, alebo Lifetime za $29.99 jednorazovo. Platba ide cez Apple ID a predplatné sa obnovuje automaticky.",
    ),
    "sl": profile(
        "Cribbage Trainer: Vadi",
        "Štetje, pegging in odmetavanje",
        "cribbage,karte,točke,pegging,crib,odmetavanje,štetje,začetnik,lekcija,vaja,pravila,strategija,kviz",
        "Novost: Endless Practice vsakič razdeli novo kombinacijo. Ponavljaj napake in izboljšaj rekord v 90-sekundnem izzivu.",
        "Vadi štetje, točkovanje, odmetavanje in pegging v štirih brezplačnih sobah.",
        "Vadi cribbage s standardnim kompletom v petminutnih seansah. Brez nasprotnikov, pritiska ali računa.",
        "Sobe za karte, točkovanje, odmetavanje in pegging. Vadi 15, 31, pare, zaporedja, go in zadnjo karto.",
        "Cribbage+ doda Endless Practice, ponavljanje napak, 90-sekundni izziv, dodatne sklope in Master Tables. Osnove ostanejo brezplačne.",
        "Cribbage+ stane $1.99 mesečno ali $9.99 letno, oba načrta z brezplačnim tednom preizkusa, ali Lifetime $29.99 enkratno. Plačilo poteka prek Apple ID in naročnina se samodejno obnovi.",
    ),
    "sv": profile(
        "Cribbage Trainer: Träna",
        "Räkna, pegging och crib",
        "cribbage,kort,poäng,pegging,crib,kasta,räkna,nybörjare,lektion,övning,regler,strategi,quiz",
        "Nytt: Endless Practice delar en ny hand varje gång. Repetera fel och jaga ditt rekord i 90-sekundersutmaningen.",
        "Träna på räkning, poäng, kast och pegging i fyra kostnadsfria rum.",
        "Träna cribbage med en vanlig kortlek i femminuterspass. Inga motståndare, ingen press och inget konto.",
        "Rum för kort, poäng, kast och pegging. Träna 15, 31, par, serier, go och det sista kortet.",
        "Cribbage+ ger Endless Practice, repetition av fel, en 90-sekundersutmaning, extra set och Master Tables. Grunderna är gratis.",
        "Cribbage+ kostar $1.99 per månad eller $9.99 per år, båda med en gratis provvecka, eller Lifetime för $29.99 som engångsköp. Betalning sker via Apple ID och förnyas automatiskt.",
    ),
    "uk": profile(
        "Cribbage Trainer: Практика",
        "Підрахунок, пеггінг і скидання",
        "крибедж,карти,очки,пеггінг,криб,скидання,підрахунок,початківець,урок,тренування,правила,стратегія,вікторина",
        "Новинка: Endless Practice щоразу роздає нову руку. Повторюйте помилки та покращуйте рекорд у випробуванні на 90 секунд.",
        "Тренуйте підрахунок, очки, скидання і пеггінг у чотирьох безкоштовних кімнатах.",
        "Вивчайте крибедж зі стандартною колодою у п'ятихвилинних сесіях. Без суперників, тиску чи облікового запису.",
        "Кімнати Карт, Підрахунку, Скидання і Пеггінгу. Тренуйте 15, 31, пари, послідовності, go і останню карту.",
        "Cribbage+ додає Endless Practice, повторення помилок, випробування на 90 секунд, додаткові набори та Master Tables. Основи залишаються безкоштовними.",
        "Cribbage+ коштує $1.99 на місяць або $9.99 на рік, обидва плани мають безкоштовний тиждень, або Lifetime за $29.99 одноразово. Оплата списується з Apple ID, а підписка поновлюється автоматично.",
    ),
    "en-GB": profile(
        "Cribbage Trainer: Count & Peg",
        "Counting, Pegging & Discards",
        "cribbage,practice,scoring,pegging,discard,crib,counting,beginner,lesson,drill,rule,defence,strategy,quiz",
        "New: Endless Practice deals a fresh hand every time. Review mistakes and chase your best score in the 90-second challenge.",
        "Practise counting, scoring, discarding and pegging in four free rooms.",
        "Practise standard-deck cribbage in five-minute sessions. No opponents, pressure or account required.",
        "Card, scoring, discard and pegging rooms. Practise 15, 31, pairs, runs, go and the last card.",
        "Cribbage+ adds Endless Practice, mistake review, a 90-second challenge, extra sets and Master Tables. The basics stay free.",
        "Cribbage+ costs $1.99 monthly or $9.99 yearly, both with a one-week free trial, or Lifetime for $29.99 once. Payment uses your Apple ID and renews automatically unless cancelled.",
    ),
    "en-AU": profile(
        "Cribbage Trainer: Count & Peg",
        "Counting, Pegging & Discards",
        "cribbage,practice,scoring,pegging,discard,crib,counting,beginner,lesson,drill,rule,defence,strategy,quiz",
        "New: Endless Practice deals a fresh hand every time. Review mistakes and chase your best score in the 90-second challenge.",
        "Practise counting, scoring, discarding and pegging in four free rooms.",
        "Practise standard-deck cribbage in five-minute sessions. No opponents, pressure or account required.",
        "Card, scoring, discard and pegging rooms. Practise 15, 31, pairs, runs, go and the last card.",
        "Cribbage+ adds Endless Practice, mistake review, a 90-second challenge, extra sets and Master Tables. The basics stay free.",
        "Cribbage+ costs $1.99 monthly or $9.99 yearly, both with a one-week free trial, or Lifetime for $29.99 once. Payment uses your Apple ID and renews automatically unless cancelled.",
    ),
    "en-CA": profile(
        "Cribbage Trainer: Count & Peg",
        "Counting, Pegging & Discards",
        "cribbage,practice,scoring,pegging,discard,crib,counting,beginner,lesson,drill,rule,defence,strategy,quiz",
        "New: Endless Practice deals a fresh hand every time. Review mistakes and chase your best score in the 90-second challenge.",
        "Practise counting, scoring, discarding and pegging in four free rooms.",
        "Practise standard-deck cribbage in five-minute sessions. No opponents, pressure or account required.",
        "Card, scoring, discard and pegging rooms. Practise 15, 31, pairs, runs, go and the last card.",
        "Cribbage+ adds Endless Practice, mistake review, a 90-second challenge, extra sets and Master Tables. The basics stay free.",
        "Cribbage+ costs $1.99 monthly or $9.99 yearly, both with a one-week free trial, or Lifetime for $29.99 once. Payment uses your Apple ID and renews automatically unless cancelled.",
    ),
    "hi": profile(
        "Cribbage Trainer: अभ्यास",
        "अंक, पेगिंग और कार्ड छोड़ना",
        "क्रिबेज,कार्ड,अंक,पेगिंग,क्रिब,गिनती,अभ्यास,शुरुआती,पाठ,नियम,रणनीति,क्विज़",
        "नया: Endless Practice हर बार नया हाथ देता है। गलतियों को दोहराएँ और 90 सेकंड की चुनौती में अपना रिकॉर्ड बेहतर करें।",
        "चार मुफ़्त कमरों में गिनती, अंक, कार्ड छोड़ना और पेगिंग का अभ्यास करें।",
        "मानक ताश की गड्डी से क्रिबेज को पाँच मिनट के अभ्यास में सीखें। प्रतिद्वंद्वी, दबाव या खाता आवश्यक नहीं है।",
        "कार्ड, अंक, कार्ड छोड़ने और पेगिंग के कमरे। 15, 31, जोड़ियों, रन, go और आखिरी कार्ड का अभ्यास करें।",
        "Cribbage+ में Endless Practice, गलतियों की समीक्षा, 90 सेकंड की चुनौती, अतिरिक्त सेट और Master Tables मिलते हैं। मूल सामग्री मुफ़्त है।",
        "Cribbage+ $1.99 मासिक या $9.99 वार्षिक है, दोनों में एक सप्ताह का मुफ़्त परीक्षण, या $29.99 का एक बार का Lifetime विकल्प। भुगतान Apple ID से लिया जाता है और सदस्यता अपने आप नवीनीकृत होती है।",
    ),
    "bn": profile(
        "Cribbage Trainer: ক্রিবেজ",
        "অঙ্ক, পেগিং ও তাস বাদ",
        "ক্রিবেজ,তাস,অঙ্ক,পেগিং,ক্রিব,গণনা,অনুশীলন,নতুন,পাঠ,নিয়ম,কৌশল,কুইজ",
        "নতুন: Endless Practice প্রতিবার নতুন হাত দেয়। ভুলগুলো আবার অনুশীলন করুন এবং ৯০ সেকেন্ডের চ্যালেঞ্জে রেকর্ড গড়ুন।",
        "চারটি বিনামূল্যের ঘরে ক্রিবেজের গণনা, পয়েন্ট, তাস বাদ দেওয়া ও পেগিং অনুশীলন করুন।",
        "মানক তাসের প্যাক দিয়ে পাঁচ মিনিটের অনুশীলনে ক্রিবেজ শিখুন। প্রতিপক্ষ, চাপ বা অ্যাকাউন্টের প্রয়োজন নেই।",
        "তাস, পয়েন্ট, তাস বাদ ও পেগিংয়ের ঘর। ১৫, ৩১, জোড়া, রান, go এবং শেষ তাস অনুশীলন করুন।",
        "Cribbage+ এ Endless Practice, ভুলের পুনরাবৃত্তি, ৯০ সেকেন্ডের চ্যালেঞ্জ, অতিরিক্ত সেট ও Master Tables রয়েছে। মূল বিষয়গুলো বিনামূল্যে।",
        "Cribbage+ মাসে $1.99 বা বছরে $9.99, দুটিতেই এক সপ্তাহের বিনামূল্যের ট্রায়াল, অথবা একবারে Lifetime $29.99। পেমেন্ট Apple ID থেকে নেওয়া হয় এবং সাবস্ক্রিপশন স্বয়ংক্রিয়ভাবে নবায়ন হয়।",
    ),
    "gu": profile(
        "Cribbage Trainer: ક્રિબેજ",
        "ગુણ, પેગિંગ અને પત્તાં",
        "ક્રિબેજ,પત્તાં,ગુણ,પેગિંગ,ક્રિબ,ગણતરી,અભ્યાસ,શરૂઆત,પાઠ,નિયમ,વ્યૂહ,ક્વિઝ",
        "નવું: Endless Practice દર વખતે નવો હાથ આપે છે. ભૂલો ફરી શીખો અને 90 સેકન્ડના પડકારમાં તમારો રેકોર્ડ સુધારો.",
        "ચાર મફત રૂમમાં ક્રિબેજની ગણતરી, ગુણ, પત્તાં કાઢવા અને પેગિંગનો અભ્યાસ કરો.",
        "માનક પત્તાની ગડી સાથે પાંચ મિનિટના અભ્યાસમાં ક્રિબેજ શીખો. વિરોધી, દબાણ કે ખાતું જરૂરી નથી.",
        "પત્તાં, ગુણ, પત્તાં કાઢવા અને પેગિંગના રૂમ. 15, 31, જોડી, રન, go અને છેલ્લું પત્તું શીખો.",
        "Cribbage+ માં Endless Practice, ભૂલોનું પુનરાવર્તન, 90 સેકન્ડનો પડકાર, વધારાના સેટ અને Master Tables મળે છે. મૂળ સામગ્રી મફત છે.",
        "Cribbage+ દર મહિને $1.99 અથવા વર્ષે $9.99, બંનેમાં એક અઠવાડિયાની મફત અજમાયશ, અથવા એક વખતનું Lifetime $29.99. ચુકવણી Apple IDથી થાય છે અને સબ્સ્ક્રિપ્શન આપમેળે નવીકરણ થાય છે.",
    ),
    "kn": profile(
        "Cribbage Trainer: ಕ್ರಿಬೇಜ್",
        "ಅಂಕ, ಪೆಗ್ಗಿಂಗ್ ಮತ್ತು ಎಸೆಯುವಿಕೆ",
        "ಕ್ರಿಬೇಜ್,ಕಾರ್ಡ್,ಅಂಕ,ಪೆಗ್ಗಿಂಗ್,ಕ್ರಿಬ್,ಎಣಿಕೆ,ಅಭ್ಯಾಸ,ಆರಂಭಿಕ,ಪಾಠ,ನಿಯಮ,ತಂತ್ರ,ಕ್ವಿಜ್",
        "ಹೊಸತು: Endless Practice ಪ್ರತಿ ಬಾರಿ ಹೊಸ ಕೈ ನೀಡುತ್ತದೆ. ತಪ್ಪುಗಳನ್ನು ಮತ್ತೆ ಅಭ್ಯಾಸ ಮಾಡಿ 90 ಸೆಕೆಂಡ್ ಸವಾಲಿನಲ್ಲಿ ದಾಖಲೆ ಮುರಿಯಿರಿ.",
        "ನಾಲ್ಕು ಉಚಿತ ಕೊಠಡಿಗಳಲ್ಲಿ ಕ್ರಿಬೇಜ್ ಎಣಿಕೆ, ಅಂಕ, ಕಾರ್ಡ್ ಎಸೆಯುವಿಕೆ ಮತ್ತು ಪೆಗ್ಗಿಂಗ್ ಅಭ್ಯಾಸ ಮಾಡಿ.",
        "ಸಾಮಾನ್ಯ ಕಾರ್ಡ್ ಡೆಕ್‌ನಿಂದ ಐದು ನಿಮಿಷದ ಅಭ್ಯಾಸದಲ್ಲಿ ಕ್ರಿಬೇಜ್ ಕಲಿಯಿರಿ. ಎದುರಾಳಿ, ಒತ್ತಡ ಅಥವಾ ಖಾತೆ ಅಗತ್ಯವಿಲ್ಲ.",
        "ಕಾರ್ಡ್, ಅಂಕ, ಎಸೆಯುವಿಕೆ ಮತ್ತು ಪೆಗ್ಗಿಂಗ್ ಕೊಠಡಿಗಳು. 15, 31, ಜೋಡಿ, ರನ್, go ಮತ್ತು ಕೊನೆಯ ಕಾರ್ಡ್ ಅಭ್ಯಾಸ ಮಾಡಿ.",
        "Cribbage+ ನಲ್ಲಿ Endless Practice, ತಪ್ಪುಗಳ ಪುನರಾವರ್ತನೆ, 90 ಸೆಕೆಂಡ್ ಸವಾಲು, ಹೆಚ್ಚುವರಿ ಸೆಟ್‌ಗಳು ಮತ್ತು Master Tables ಇವೆ. ಮೂಲ ವಿಷಯ ಉಚಿತ.",
        "Cribbage+ ತಿಂಗಳಿಗೆ $1.99 ಅಥವಾ ವರ್ಷಕ್ಕೆ $9.99, ಎರಡರಲ್ಲೂ ಒಂದು ವಾರದ ಉಚಿತ ಪ್ರಯೋಗ, ಅಥವಾ ಒಮ್ಮೆ Lifetime $29.99. ಪಾವತಿ Apple ID ಮೂಲಕ ನಡೆಯುತ್ತದೆ ಮತ್ತು ಚಂದಾದಾರಿಕೆ ಸ್ವಯಂಚಾಲಿತವಾಗಿ ನವೀಕರಿಸುತ್ತದೆ.",
    ),
    "ml": profile(
        "Cribbage Trainer: ക്രിബേജ്",
        "പോയിന്റ്, പെഗ്ഗിംഗ്, നീക്കം",
        "ക്രിബേജ്,കാർഡ്,പോയിന്റ്,പെഗ്ഗിംഗ്,ക്രിബ്,എണ്ണൽ,പരിശീലനം,തുടക്കം,പാഠം,നിയമം,തന്ത്രം,ക്വിസ്",
        "പുതിയത്: Endless Practice ഓരോ തവണയും പുതിയ കൈ നൽകുന്നു. തെറ്റുകൾ വീണ്ടും പരിശീലിച്ച് 90 സെക്കൻഡ് ചലഞ്ചിൽ റെക്കോർഡ് മെച്ചപ്പെടുത്തൂ.",
        "നാല് സൗജന്യ മുറികളിൽ ക്രിബേജ് എണ്ണൽ, പോയിന്റ്, കാർഡ് നീക്കം, പെഗ്ഗിംഗ് എന്നിവ പരിശീലിക്കൂ.",
        "സാധാരണ കാർഡ് ഡെക്കുമായി അഞ്ച് മിനിറ്റ് പരിശീലനത്തിൽ ക്രിബേജ് പഠിക്കൂ. എതിരാളിയോ അക്കൗണ്ടോ ആവശ്യമില്ല.",
        "കാർഡ്, പോയിന്റ്, നീക്കം, പെഗ്ഗിംഗ് മുറികൾ. 15, 31, ജോഡി, റൺ, go, അവസാന കാർഡ് എന്നിവ പരിശീലിക്കൂ.",
        "Cribbage+ ൽ Endless Practice, തെറ്റുകളുടെ ആവർത്തനം, 90 സെക്കൻഡ് ചലഞ്ച്, അധിക സെറ്റുകൾ, Master Tables എന്നിവ ലഭിക്കും. അടിസ്ഥാന ഉള്ളടക്കം സൗജന്യം.",
        "Cribbage+ മാസം $1.99 അല്ലെങ്കിൽ വർഷം $9.99, രണ്ടിലും ഒരാഴ്ച സൗജന്യ പരീക്ഷണം, അല്ലെങ്കിൽ ഒറ്റത്തവണ Lifetime $29.99. പണം Apple IDയിൽ നിന്ന് ഈടാക്കുകയും സബ്സ്ക്രിപ്ഷൻ സ്വയം പുതുക്കുകയും ചെയ്യും.",
    ),
    "mr": profile(
        "Cribbage Trainer: सराव",
        "गुण, पेगिंग आणि पत्ते टाकणे",
        "क्रिबेज,पत्ते,गुण,पेगिंग,क्रिब,मोजणी,सराव,नवशिके,धडा,नियम,डावपेच,क्विझ",
        "नवीन: Endless Practice प्रत्येक वेळी नवीन हात देते. चुका पुन्हा पाहा आणि 90 सेकंदांच्या आव्हानात विक्रम मोडा.",
        "चार मोफत खोल्यांमध्ये क्रिबेजची मोजणी, गुण, पत्ते टाकणे आणि पेगिंगचा सराव करा.",
        "मानक पत्त्यांच्या संचासह पाच मिनिटांच्या सरावात क्रिबेज शिका. प्रतिस्पर्धी, दबाव किंवा खाते आवश्यक नाही.",
        "पत्ते, गुण, पत्ते टाकणे आणि पेगिंगच्या खोल्या. 15, 31, जोड्या, रन, go आणि शेवटचा पत्ता शिका.",
        "Cribbage+ मध्ये Endless Practice, चुकांचे पुनरावलोकन, 90 सेकंदांचे आव्हान, अतिरिक्त संच आणि Master Tables मिळतात. मूलभूत सामग्री मोफत आहे.",
        "Cribbage+ दरमहा $1.99 किंवा दरवर्षी $9.99, दोन्हीसोबत एक आठवड्याची मोफत चाचणी, किंवा एकदाच Lifetime $29.99. देयक Apple ID वर आकारले जाते आणि सदस्यता आपोआप नूतनीकरण होते.",
    ),
    "or": profile(
        "Cribbage Trainer: କ୍ରିବେଜ୍",
        "ପଏଣ୍ଟ, ପେଗିଙ୍ଗ ଓ କାର୍ଡ",
        "କ୍ରିବେଜ୍,କାର୍ଡ,ପଏଣ୍ଟ,ପେଗିଙ୍ଗ,କ୍ରିବ୍,ଗଣନା,ଅଭ୍ୟାସ,ନୂଆ,ପାଠ,ନିୟମ,କୌଶଳ,କୁଇଜ୍",
        "ନୂଆ: Endless Practice ପ୍ରତିଥର ନୂଆ ହାତ ଦିଏ। ଭୁଲଗୁଡ଼ିକ ପୁଣି ଅଭ୍ୟାସ କରନ୍ତୁ ଏବଂ ୯୦ ସେକେଣ୍ଡ ଚ୍ୟାଲେଞ୍ଜରେ ରେକର୍ଡ କରନ୍ତୁ।",
        "ଚାରିଟି ମାଗଣା କକ୍ଷରେ କ୍ରିବେଜ୍ ଗଣନା, ପଏଣ୍ଟ, କାର୍ଡ ଛାଡ଼ିବା ଓ ପେଗିଙ୍ଗ ଅଭ୍ୟାସ କରନ୍ତୁ।",
        "ସାଧାରଣ କାର୍ଡ ଗଡ଼ି ସହ ପାଞ୍ଚ ମିନିଟର ଅଭ୍ୟାସରେ କ୍ରିବେଜ୍ ଶିଖନ୍ତୁ। ପ୍ରତିଦ୍ୱନ୍ଦ୍ୱୀ କିମ୍ବା ଖାତା ଦରକାର ନାହିଁ।",
        "କାର୍ଡ, ପଏଣ୍ଟ, ଛାଡ଼ିବା ଓ ପେଗିଙ୍ଗ କକ୍ଷ। ୧୫, ୩୧, ଯୋଡ଼ି, ରନ୍, go ଓ ଶେଷ କାର୍ଡ ଅଭ୍ୟାସ କରନ୍ତୁ।",
        "Cribbage+ ରେ Endless Practice, ଭୁଲ ପୁନରାବୃତ୍ତି, ୯୦ ସେକେଣ୍ଡ ଚ୍ୟାଲେଞ୍ଜ, ଅତିରିକ୍ତ ସେଟ୍ ଓ Master Tables ମିଳେ। ମୂଳ ବିଷୟ ମାଗଣା।",
        "Cribbage+ ମାସକୁ $1.99 କିମ୍ବା ବର୍ଷକୁ $9.99, ଉଭୟରେ ଏକ ସପ୍ତାହର ମାଗଣା ପରୀକ୍ଷା, କିମ୍ବା ଏକଥର Lifetime $29.99। ଦେୟ Apple ID ରୁ ନିଆଯାଏ ଏବଂ ସଦସ୍ୟତା ଆପେ ନବୀକରଣ ହୁଏ।",
    ),
    "pa": profile(
        "Cribbage Trainer: ਕ੍ਰਿਬੇਜ",
        "ਅੰਕ, ਪੇਗਿੰਗ ਅਤੇ ਪੱਤੇ ਸੁੱਟੋ",
        "ਕ੍ਰਿਬੇਜ,ਤਾਸ਼,ਅੰਕ,ਪੇਗਿੰਗ,ਕ੍ਰਿਬ,ਗਿਣਤੀ,ਅਭਿਆਸ,ਸ਼ੁਰੂਆਤੀ,ਪਾਠ,ਨਿਯਮ,ਰਣਨੀਤੀ,ਕੁਇਜ਼",
        "ਨਵਾਂ: Endless Practice ਹਰ ਵਾਰ ਨਵਾਂ ਹੱਥ ਦਿੰਦਾ ਹੈ। ਗਲਤੀਆਂ ਦੁਹਰਾਓ ਅਤੇ 90 ਸਕਿੰਟ ਦੀ ਚੁਣੌਤੀ ਵਿੱਚ ਰਿਕਾਰਡ ਬਣਾਓ।",
        "ਚਾਰ ਮੁਫ਼ਤ ਕਮਰਿਆਂ ਵਿੱਚ ਕ੍ਰਿਬੇਜ ਦੀ ਗਿਣਤੀ, ਅੰਕ, ਪੱਤੇ ਸੁੱਟਣ ਅਤੇ ਪੇਗਿੰਗ ਦਾ ਅਭਿਆਸ ਕਰੋ।",
        "ਮਿਆਰੀ ਤਾਸ਼ ਦੀ ਗੱਡੀ ਨਾਲ ਪੰਜ ਮਿੰਟ ਦੇ ਅਭਿਆਸ ਵਿੱਚ ਕ੍ਰਿਬੇਜ ਸਿੱਖੋ। ਵਿਰੋਧੀ, ਦਬਾਅ ਜਾਂ ਖਾਤਾ ਲੋੜੀਂਦਾ ਨਹੀਂ।",
        "ਤਾਸ਼, ਅੰਕ, ਪੱਤੇ ਸੁੱਟਣ ਅਤੇ ਪੇਗਿੰਗ ਦੇ ਕਮਰੇ। 15, 31, ਜੋੜੀਆਂ, ਰਨ, go ਅਤੇ ਆਖਰੀ ਪੱਤਾ ਅਭਿਆਸ ਕਰੋ।",
        "Cribbage+ ਵਿੱਚ Endless Practice, ਗਲਤੀਆਂ ਦੀ ਸਮੀਖਿਆ, 90 ਸਕਿੰਟ ਦੀ ਚੁਣੌਤੀ, ਵਾਧੂ ਸੈੱਟ ਅਤੇ Master Tables ਮਿਲਦੇ ਹਨ। ਮੁੱਢਲੀ ਸਮੱਗਰੀ ਮੁਫ਼ਤ ਹੈ।",
        "Cribbage+ ਮਹੀਨੇ ਦੇ $1.99 ਜਾਂ ਸਾਲ ਦੇ $9.99, ਦੋਵਾਂ ਨਾਲ ਇੱਕ ਹਫ਼ਤੇ ਦੀ ਮੁਫ਼ਤ ਅਜ਼ਮਾਇਸ਼, ਜਾਂ ਇੱਕ ਵਾਰ Lifetime $29.99। ਭੁਗਤਾਨ Apple ID ਤੋਂ ਲਿਆ ਜਾਂਦਾ ਹੈ ਅਤੇ ਮੈਂਬਰਸ਼ਿਪ ਆਪਣੇ ਆਪ ਨਵੀਨ ਹੁੰਦੀ ਹੈ।",
    ),
    "ta": profile(
        "Cribbage Trainer: கிரிபேஜ்",
        "மதிப்பெண், பெக்கிங், சீட்டுகள்",
        "கிரிபேஜ்,சீட்டு,மதிப்பெண்,பெக்கிங்,கிரிப்,எண்ணிக்கை,பயிற்சி,தொடக்கம்,பாடம்,விதி,தந்திரம்,வினாடி வினா",
        "புதியது: Endless Practice ஒவ்வொரு முறையும் புதிய கையை வழங்கும். தவறுகளை மீண்டும் பயிற்சி செய்து 90 விநாடி சவாலில் சாதனை படையுங்கள்.",
        "நான்கு இலவச அறைகளில் கிரிபேஜ் எண்ணிக்கை, மதிப்பெண், சீட்டு விடுதல் மற்றும் பெக்கிங் பயிற்சி செய்யுங்கள்.",
        "நிலையான சீட்டு கட்டுடன் ஐந்து நிமிட பயிற்சியில் கிரிபேஜ் கற்றுக்கொள்ளுங்கள். எதிரணி, அழுத்தம் அல்லது கணக்கு தேவையில்லை.",
        "சீட்டு, மதிப்பெண், விடுதல் மற்றும் பெக்கிங் அறைகள். 15, 31, ஜோடிகள், ரன், go மற்றும் கடைசி சீட்டைப் பயிற்சி செய்யுங்கள்.",
        "Cribbage+ இல் Endless Practice, தவறுகளின் மறுபயிற்சி, 90 விநாடி சவால், கூடுதல் தொகுப்புகள் மற்றும் Master Tables உள்ளன. அடிப்படை இலவசம்.",
        "Cribbage+ மாதம் $1.99 அல்லது ஆண்டு $9.99, இரண்டிலும் ஒரு வார இலவச சோதனை, அல்லது ஒருமுறை Lifetime $29.99. பணம் Apple IDயில் வசூலிக்கப்படும், சந்தா தானாக புதுப்பிக்கும்.",
    ),
    "te": profile(
        "Cribbage Trainer: క్రిబేజ్",
        "స్కోర్, పెగ్గింగ్, కార్డులు",
        "క్రిబేజ్,కార్డులు,స్కోర్,పెగ్గింగ్,క్రిబ్,లెక్కింపు,సాధన,ప్రారంభం,పాఠం,నియమం,వ్యూహం,క్విజ్",
        "కొత్తది: Endless Practice ప్రతిసారీ కొత్త చేతిని ఇస్తుంది. తప్పులను మళ్లీ సాధన చేసి 90 సెకన్ల సవాల్‌లో రికార్డు సాధించండి.",
        "నాలుగు ఉచిత గదుల్లో క్రిబేజ్ లెక్కింపు, స్కోర్, కార్డులు వదలడం మరియు పెగ్గింగ్ సాధన చేయండి.",
        "సాధారణ కార్డుల డెక్‌తో ఐదు నిమిషాల సాధనలో క్రిబేజ్ నేర్చుకోండి. ప్రత్యర్థి, ఒత్తిడి లేదా ఖాతా అవసరం లేదు.",
        "కార్డులు, స్కోర్, వదలడం మరియు పెగ్గింగ్ గదులు. 15, 31, జంటలు, రన్, go మరియు చివరి కార్డును సాధన చేయండి.",
        "Cribbage+లో Endless Practice, తప్పుల పునరావృతం, 90 సెకన్ల సవాలు, అదనపు సెట్లు మరియు Master Tables ఉంటాయి. ప్రాథమిక విషయాలు ఉచితం.",
        "Cribbage+ నెలకు $1.99 లేదా సంవత్సరానికి $9.99, రెండింటిలో ఒక వారం ఉచిత ట్రయల్, లేదా ఒకసారి Lifetime $29.99. చెల్లింపు Apple ID నుంచి తీసుకోబడుతుంది మరియు సభ్యత్వం ఆటోమేటిక్‌గా పునరుద్ధరించబడుతుంది.",
    ),
    "ur": profile(
        "Cribbage Trainer: مشق",
        "اسکور، پیگنگ اور پتے",
        "کریبج,تاش,اسکور,پیگنگ,کریب,پتےپھینکنا,گنتی,ابتدائی,سبق,مشق,قواعد,حکمت,کوئز",
        "نیا: Endless Practice ہر بار نیا ہاتھ تقسیم کرتا ہے۔ غلطیوں کو دہرائیں اور 90 سیکنڈ کے چیلنج میں ریکارڈ بنائیں۔",
        "چار مفت کمروں میں کریبج کی گنتی، اسکور، پتے پھینکنے اور پیگنگ کی مشق کریں۔",
        "معیاری تاش کے پیک سے پانچ منٹ کی مشق میں کریبج سیکھیں۔ حریف، دباؤ یا اکاؤنٹ کی ضرورت نہیں۔",
        "تاش، اسکور، پتے پھینکنے اور پیگنگ کے کمرے۔ 15، 31، جوڑی، رن، go اور آخری پتے کی مشق کریں۔",
        "Cribbage+ میں Endless Practice، غلطیوں کا جائزہ، 90 سیکنڈ چیلنج، اضافی سیٹ اور Master Tables شامل ہیں۔ بنیادی مواد مفت ہے۔",
        "Cribbage+ ماہانہ $1.99 یا سالانہ $9.99، دونوں میں ایک ہفتے کا مفت ٹرائل، یا ایک بار Lifetime $29.99۔ ادائیگی Apple ID سے لی جاتی ہے اور سبسکرپشن خودکار طور پر تجدید ہوتی ہے۔",
    ),
}


for regional_english in ("en-GB", "en-AU", "en-CA"):
    PROFILES[regional_english]["description"] = EN_DESCRIPTION


LOCALE_PROFILES = {
    "en-US": "en", "en-GB": "en-GB", "en-AU": "en-AU", "en-CA": "en-CA",
    "es-ES": "es", "es-MX": "es", "fr-FR": "fr", "fr-CA": "fr",
    "de-DE": "de", "it": "it", "pt-BR": "pt", "pt-PT": "pt",
    "ja": "ja", "zh-Hans": "zh-Hans", "zh-Hant": "zh-Hant", "ko": "ko",
    "ar-SA": "ar", "he": "he", "nl-NL": "nl", "pl": "pl", "ru": "ru",
    "tr": "tr", "vi": "vi", "id": "id", "ms": "ms", "th": "th",
    "ca": "ca", "cs": "cs", "da": "da", "el": "el", "fi": "fi",
    "hr": "hr", "hu": "hu", "no": "no", "ro": "ro", "sk": "sk",
    "sl-SI": "sl", "sv": "sv", "uk": "uk", "hi": "hi", "mr-IN": "mr",
    "bn-BD": "bn", "gu-IN": "gu", "kn-IN": "kn", "ml-IN": "ml",
    "or-IN": "or", "pa-IN": "pa", "ta-IN": "ta", "te-IN": "te",
    "ur-PK": "ur",
}


def write_field(locale: str, field: str, value: str) -> None:
    path = METADATA / locale / f"{field}.txt"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(value.strip() + "\n", encoding="utf-8")


def fit_keywords(value: str) -> str:
    selected: list[str] = []
    for keyword in value.split(","):
        candidate = ",".join([*selected, keyword])
        if len(candidate.encode("utf-8")) > 100:
            break
        selected.append(keyword)
    return ",".join(selected)


def main() -> int:
    locales = json.loads(LOCALES_FILE.read_text(encoding="utf-8"))["locales"]
    fallback_locales: list[str] = []
    for locale in locales:
        key = LOCALE_PROFILES.get(locale, "en")
        if key == "en" and locale != "en-US":
            fallback_locales.append(locale)
        data = PROFILES[key]
        for field in ("name", "subtitle", "keywords", "description", "promotional_text", "release_notes"):
            value = fit_keywords(data[field]) if field == "keywords" else data[field]
            write_field(locale, field, value)
    print(f"Generated App Store metadata for {len(locales)} locales")
    print(f"English fallback locales: {len(fallback_locales)}")
    if fallback_locales:
        print(", ".join(fallback_locales))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
