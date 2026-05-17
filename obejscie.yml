Zamiast walczyć z zablokowanym systemem tożsamości uczelni, zastosujemy najnowocześniejsze i najbezpieczniejsze rozwiązanie w chmurze: **OpenID Connect (OIDC) z użyciem Managed Identity (Tożsamości Zarządzanej).**
### Dlaczego to zadziała?
Tożsamość Zarządzana (Managed Identity) nie jest tworzona w uczelnianym Entra ID. Jest ona traktowana jako **zwykły zasób w Azure** (dokładnie tak samo jak maszyna wirtualna czy dysk). A skoro studenci mają własne subskrypcje, mają pełne prawo tworzyć w nich zasoby! Dodatkowo OIDC pozwala na zalogowanie się z GitHuba do Azure **całkowicie bez haseł i sekretów**.
Oto całkowicie nowa wersja **Zadania 3**, zaktualizowana do tego nowoczesnego podejścia. Możesz podać ją studentom:
### Nowa instrukcja do skopiowania dla studentów:
```markdown
## Zadanie 3: Autoryzacja GitOps bez haseł (OIDC i Managed Identity)

Uczelniane systemy bezpieczeństwa często blokują tradycyjne metody autoryzacji. Zastosujemy więc podejście na poziomie eksperckim: logowanie bezhasłowe (OIDC) przy użyciu Tożsamości Zarządzanej (Managed Identity). 

**Kroki do wykonania w Azure Cloud Shell:**
1. Otwórz terminal Azure Cloud Shell w przeglądarce.
2. Zmodyfikuj dwie pierwsze linijki poniższego skryptu, wpisując swój dokładny login GitHub oraz nazwę repozytorium (uwaga na wielkość liter!), a następnie wklej i uruchom całość w terminalu:

```bash
GITHUB_USER="TwójLoginGitHub"
GITHUB_REPO="NazwaTwojegoRepozytorium"

# 1. Tworzenie grupy zasobów dla tożsamości
az group create --name RG-GitHub-Auth --location westeurope

# 2. Tworzenie Tożsamości Zarządzanej (To omija blokady uczelniane!)
az identity create --name GHA-Identity --resource-group RG-GitHub-Auth

# 3. Pobranie danych do zmiennych
SUB_ID=$(az account show --query id -o tsv)
CLIENT_ID=$(az identity show --name GHA-Identity --resource-group RG-GitHub-Auth --query clientId -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)

# 4. Nadanie tożsamości uprawnień (Contributor) do Twojej subskrypcji
az role assignment create --role contributor --assignee $CLIENT_ID --scope /subscriptions/$SUB_ID

# 5. Konfiguracja Federacji OIDC (Powiązanie tożsamości z Twoim repozytorium na GitHubie)
az identity federated-credential create \
  --name GitHub-Federation-Main \
  --identity-name GHA-Identity \
  --resource-group RG-GitHub-Auth \
  --issuer [https://token.actions.githubusercontent.com](https://token.actions.githubusercontent.com) \
  --subject repo:$GITHUB_USER/$GITHUB_REPO:ref:refs/heads/main \
  --audiences api://AzureADTokenExchange

# 6. Wypisanie danych końcowych
echo "========================================="
echo "DODAJ TE 3 WARTOŚCI JAKO SECRETY W GITHUBIE:"
echo "AZURE_CLIENT_ID: $CLIENT_ID"
echo "AZURE_TENANT_ID: $TENANT_ID"
echo "AZURE_SUBSCRIPTION_ID: $SUB_ID"
echo "========================================="

```
 3. Skrypt zwróci Ci na końcu 3 ciągi znaków.
 4. Przejdź na GitHuba -> **Settings** -> **Secrets and variables** -> **Actions**.
 5. Dodaj 3 nowe sekrety (New repository secret). Ich nazwy muszą być dokładnie takie jak wyżej: AZURE_CLIENT_ID, AZURE_TENANT_ID oraz AZURE_SUBSCRIPTION_ID, a w polach Secret wklej odpowiadające im wygenerowane ciągi.
```

---

### Ważna modyfikacja potoków YAML (Dla Ciebie)

Ponieważ przeszliśmy z pojedynczego hasła JSON na bezhasłowe uwierzytelnianie OIDC, musisz dokonać **dwóch drobnych zmian** w plikach YAML (`task5-terraform.yml`, `task6-cd.yml`, `task7-e2e.yml`).

1. Na samej górze plików YAML, w sekcji `permissions`, MUSI pojawić się linijka `id-token: write`. Jest to niezbędne, by GitHub wygenerował żeton OIDC.
2. W kroku logowania do Azure, zmieniamy `creds:` na 3 nowe zmienne.

Oto jak powinien teraz wyglądać początek plików `.yml`:

```yaml
permissions:
  packages: write
  contents: read
  id-token: write # <--- TO JEST KRYTYCZNA NOWOŚĆ WYMAGANA PRZEZ OIDC

jobs:
  Deploy_to_Kubernetes:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Zalogowanie do chmury Azure bez hasła (OIDC)
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

```