# API campagnes promotionnelles (client Flutter)

Contrat convenu pour le backend OPISMS. **Aucun secret.** Le client Flutter est déjà branché ; l’API peut encore être absente (l’app échoue silencieusement).

## Base

`POST https://opisms.com/opisms-ws/api/v1/user/...`

Le client ajoute automatiquement `d: PROD` (form-urlencoded, comme les autres endpoints user).

Succès : `code: 0` **ou** `statut: 1`. Message : `msg` ou `message`. Liste : `datas` ou `data`.

---

## 1. Lister les campagnes actives

`POST /listecampagnes`

### Request (Bruno)

```
meta {
  name: Liste campagnes
  type: http
  seq: 1
}

post {
  url: https://opisms.com/opisms-ws/api/v1/user/listecampagnes
  body: form-urlencoded
  auth: none
}

body:form-urlencoded {
  d: PROD
  login: {{login}}
}
```

`login` = identifiant déjà utilisé à la connexion (téléphone / email). Champ optionnel côté client s’il est vide.

### Response

```json
{
  "code": 0,
  "msg": "OK",
  "datas": [
    {
      "id": "cmp_2026_01",
      "type": "popup",
      "title": "Nouvelle offre",
      "body": "Découvrez le pass famille.",
      "image_url": "https://example.com/banner.png",
      "cta_label": "Voir l'offre",
      "cta_url": "opicare://plan",
      "priority": 10,
      "frequency": "once_per_day",
      "starts_at": "2026-09-16T00:00:00Z",
      "ends_at": "2026-09-30T23:59:59Z",
      "dismissible": true
    },
    {
      "id": "off_2026_02",
      "type": "offer",
      "title": "Pass santé",
      "body": "Souscrivez en quelques taps.",
      "image_url": null,
      "cta_label": "Souscrire",
      "cta_url": "opicare://souscription",
      "priority": 5,
      "frequency": "every_open",
      "starts_at": "2026-09-16T00:00:00Z",
      "ends_at": "2026-09-30T23:59:59Z",
      "dismissible": true
    }
  ]
}
```

| Champ | Valeurs |
| --- | --- |
| `type` | `popup` \| `offer` |
| `frequency` | `once` \| `once_per_day` \| `every_open` |
| `cta_url` | Deeplink `opicare://…` ou URL `https://…` |
| `priority` | Entier, plus élevé = plus prioritaire |
| dates | ISO-8601 UTC |

Deeplinks client connus : `opicare://plan`, `opicare://souscription`, `opicare://iap`, `opicare://home`, `opicare://carnet`, `opicare://famille`, `opicare://profil`, `opicare://hopitaux`.

---

## 2. Accusé de réception

`POST /campagne/ack`

```
post {
  url: https://opisms.com/opisms-ws/api/v1/user/campagne/ack
  body: form-urlencoded
}

body:form-urlencoded {
  d: PROD
  campagne_id: cmp_2026_01
  action: dismiss
}
```

`action` : `dismiss` \| `click` \| `view`

Le client persiste aussi la fréquence en local (`SharedPreferences`). Un échec d’ack **ne bloque pas** l’app.

---

## Comportement produit (client)

1. Après login, sur **Accueil** : fetch `/listecampagnes`.
2. Au plus **une** popup (priorité max, dates valides, fréquence locale).
3. Les `offer` s’affichent en cartes sous le slider d’accueil.
4. Dismiss / CTA → ack ; CTA ouvre `cta_url`.
5. 404 / timeout / JSON invalide → aucune UI, pas de crash.

## QA sans backend

```
flutter run --dart-define=OPICARE_MOCK_CAMPAIGNS=true
```

Ou, en debug uniquement : `CampaignDebugConfig.useMockInDebug = true` (fichier `lib/features/campaigns/data/campaign_debug_config.dart`). Les titres mock sont préfixés `[MOCK]`.
