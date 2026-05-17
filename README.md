# Laboratorium: GitHub Actions & Microsoft Azure (CI/CD)

Witaj na laboratorium z automatyzacji procesów DevOps! Twoim celem na dzisiejszych zajęciach jest zbudowanie w pełni zautomatyzowanego rurociągu (pipeline), który przetestuje kod, zbuduje obraz Docker, powoła infrastrukturę w Azure za pomocą Terraforma, a na końcu wdroży aplikację na klaster Kubernetes. 

**Narzędzia, których będziesz używać:**
* Konto GitHub (GitHub Actions, GitHub Container Registry)
* Visual Studio Code (VS Code) i GitHub Desktop (do pracy z kodem)
* **Azure Cloud Shell** (wbudowana konsola w portalu Azure – do wykonywania poleceń chmurowych bez lokalnej konfiguracji)

---

## Zadanie 1: Inicjalizacja izolowanego potoku (GitHub)

Zaczynamy od napisania najprostszego potoku, aby poznać składnię YAML i architekturę GitHub Actions. Zadanie to wykonamy w całości na platformie GitHub.

**Kroki do wykonania:**
1. Zaloguj się na swoje konto na GitHubie. :)
2. Stwórz nowe, **prywne** repozytorium o nazwie `numerindeksu-lab-gha`.
3. Sklonuj repozytorium na swój komputer przy użyciu **GitHub Desktop** i otwórz je w **VS Code**.
4. W głównym katalogu repozytorium utwórz foldery: `.github/workflows/` (zwróć uwagę na kropkę na początku `.github`!).
5. Wewnątrz folderu `workflows` utwórz plik `task1-hello.yml` i wklej do niego kod z Zadania 1.
6. Zapisz plik, użyj GitHub Desktop, aby zrobić **Commit** i naciśnij **Push origin**.
7. Wejdź na stronę swojego repozytorium na GitHubie, przejdź do zakładki **Actions**.
8. Zobaczysz swój potok z lewej strony. Kliknij go i użyj przycisku **Run workflow** (ponieważ użyliśmy triggera `workflow_dispatch`).
9. Zaobserwuj, jak GitHub przydziela maszynę (Ubuntu) i wykonuje Twoje kroki.

---

## Zadanie 2: Implementacja dynamicznych mechanizmów wielowariantowych

W tym zadaniu wykorzystamy zaawansowane mechanizmy: graf zależności (`needs`), matrycę (`strategy.matrix`) oraz przesyłanie danych pomiędzy odizolowanymi maszynami (`$GITHUB_OUTPUT`).

**Kroki do wykonania:**
1. W folderze `.github/workflows/` utwórz plik `task2-matrix.yml` i skopiuj do niego przygotowany kod.
2. Przeanalizuj komentarze w kodzie. Zauważ, że `Zadanie_B` uruchomi się automatycznie w 3 równoległych wariantach dla różnych systemów operacyjnych.
3. Zrób Commit i Push.
4. Uruchom workflow w zakładce **Actions** i sprawdź logi z `Zadanie_B`, aby zobaczyć wartość przekazaną z `Zadanie_A`.

---

## Zadanie 3: Uniezależnienie tożsamości i uwierzytelnianie potoku w Azure

Aby GitHub mógł cokolwiek zrobić w chmurze Azure (np. powołać infrastrukturę), musi się autoryzować. Tworzymy tzw. **Service Principal** (Konto Serwisowe).

*Zamiast logować się lokalnie w terminalu, zrobimy to szybciej w chmurze!*

**Kroki do wykonania:**
1. Otwórz portal Azure w przeglądarce i uruchom **Azure Cloud Shell** (ikonka terminala na górnym pasku, wybierz Bash).
2. Sprawdź swoje ID Subskrypcji wpisując:
   `az account show --query id -o tsv`
   *(Skopiuj wyświetlony identyfikator).*
3. Wygeneruj Service Principal (zastąp `<TWOJE_ID_SUBSKRYPCJI>` skopiowanym ID):
   `az ad sp create-for-rbac --name "GitHub-Actions-Pipeline" --role contributor --scopes /subscriptions/<TWOJE_ID_SUBSKRYPCJI> --sdk-auth`
4. Komenda zwróci na ekranie duży obiekt w formacie JSON (zaczynający się od `{` i kończący na `}`). **Skopiuj go w całości.**
5. Przejdź na stronę swojego repozytorium na GitHubie.
6. Wejdź w **Settings** -> **Secrets and variables** (w lewym menu) -> **Actions**.
7. Kliknij zielony przycisk **New repository secret**.
8. W polu *Name* wpisz dokładnie: `AZURE_CREDENTIALS`
9. W polu *Secret* wklej skopiowany wcześniej kod JSON.
10. Kliknij **Add secret**. Twoja automatyzacja ma teraz uprawnienia do Azure!

---

## Zadanie 4: Publikacja artefaktów aplikacyjnych (GHCR)

Zbudujemy obraz Docker z prostą aplikacją i wrzucimy go do darmowego rejestru wbudowanego w GitHuba (GitHub Container Registry). 

*Pamiętaj o różnicy między Magazynem a Serwerem! W tym kroku aplikacja nie zostanie nigdzie uruchomiona. Obraz to tylko "przepis" zapakowany w cyfrową paczkę, która odkładana jest na półkę w magazynie (GHCR).*

**Kroki do wykonania:**
1. W głównym folderze repozytorium utwórz folder `src`. 
2. W folderze `src` utwórz dwa pliki: skrypt `app.py` oraz `Dockerfile`.
3. W folderze `.github/workflows/` utwórz plik `task4-docker.yml`.
4. **Ważne:** Zmień w kodzie YAML `ghcr.io/<TWOJ_LOGIN_GITHUB>/python-proxy` podając swój dokładny login z GitHuba (używaj tylko małych liter!).
5. Zrób Commit i Push. Zobacz w zakładce Actions jak potok buduje obraz.
6. Na stronie głównej repozytorium, z prawej strony poszukaj sekcji **Packages** - pojawi się tam Twój obraz!

---

## Zadanie 5: Orkiestracja zasobów za pomocą Terraform (AKS)

Czas przygotować infrastrukturę. Zbudujemy klaster Kubernetes w chmurze Azure.

**Kroki do wykonania:**
1. W głównym folderze stwórz katalog `terraform`.
2. Dodaj do niego plik `main.tf` i uzupełnij go kodem z gotowca.
3. Dodaj plik `task5-terraform.yml` do `.github/workflows/`.
4. Zrób Commit i Push. 
5. Uruchom workflow ręcznie w GitHubie. Budowa klastra AKS zajmie ok. 5 minut.
*(Zauważ: Używamy tu stanu lokalnego na potrzeby zajęć. Wszystko dzieje się w pełni automatycznie przez potok CI).*

---

## Zadanie 6: CD jako proces manualny z kryptograficznym SHA

W tym zadaniu połączymy kroki budowania obrazu z krokiem aktualizacji kodu na klastrze. Użyjemy najlepszych praktyk: zamiast tagu `:latest`, potok użyje identyfikatora commita (`${{ github.sha }}`), by Kubernetes zawsze wiedział, że ma pobrać nową warstwę. Potok uruchamiany jest ręcznie.

**Kroki do wykonania:**
1. Utwórz folder `k8s` w głównym katalogu i dodaj do niego plik `deployment.yaml`.
2. Wgraj potok `task6-cd.yml` do folderu `.github/workflows/` z dostarczonych materiałów.
3. W pliku YAML zaktualizuj ścieżkę obrazu na swój profil (DWÓCH miejscach!).
4. Zmień słowo w pliku `src/app.py` (np. na "Wersja Manualna Zadania 6").
5. Zrób Commit i Push za pomocą GitHub Desktop.
6. Przejdź do zakładki **Actions** w GitHubie, wybierz *Zadanie 6* i kliknij **Run workflow**.
7. **Weryfikacja w chmurze:** Otwórz *Azure Cloud Shell* w przeglądarce i zautoryzuj się w klasterze komendą:
   `az aks get-credentials --resource-group RG-DevOps-Lab --name aks-devops-lab`
   A następnie sprawdź adres IP: `kubectl get svc proxy-service -w`
   Wklej publiczny adres IP do przeglądarki. Zmiana będzie po chwili (jak skończy się pipe) widoczna!

```mermaid
flowchart TD
    A[Kod] --> B[CI]
    B --> C[Docker image]
    C --> D[Registry]
    D --> E[CD]
    E --> F[AKS]
```


---

## Zadanie 7: WYZWANIE - Pełna automatyzacja GitOps 

Bazując na potoku z zadania 6 utworzy nowy `task7-.yml`. Tym razem wymaga to lektury dokumentacji!

**Warunki wyzwania (Oczekiwany kształt YAML-a):**
1. **Automatyczny Trigger z filtrowaniem ścieżek:** Potok uruchamia się samoczynnie po zrobieniu `push` do gałęzi `main`. **Uwaga:** Ma reagować TYLKO WTEDY, gdy zmiana nastąpiła w katalogu `src/` lub jego podfolderach. (Zmiana w np. README.MD nie powinna wyzwalać potoku dla aplikacji!).
2. **Bramka Jakości (Nowe Zadanie):** Dodaj zupełnie nowe zadanie (Job) na samej górze pliku o nazwie `Code_Quality_Check`. Ma ono działać na `ubuntu-latest`, pobrać kod i wykonać komendę `python -m py_compile src/app.py` w celu sprawdzenia składni.
3. **Złożony Graf Zależności (3 etapy):** - Zadanie `Build_and_Push` może wystartować TYLKO po sukcesie zadania `Code_Quality_Check`.
   - Zadanie `Deploy_to_Kubernetes` może wystartować TYLKO po sukcesie `Build_and_Push`.
   
**Gdzie szukać pomocy w oficjalnej dokumentacji?**
* Wyzwalanie po push z filtrowaniem plików (`paths`): [GitHub Docs - on.push.paths](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#push)
* Definiowanie zależności zadań (needs): [GitHub Docs - Defining prerequisite jobs](https://docs.github.com/en/actions/using-jobs/using-jobs-in-a-workflow#defining-prerequisite-jobs)

**Testy** Zmień napis w `src/app.py`, zrób Commit i Push. Usiądź wygodnie – potok sam sprawdzi kod, wybuduje go i wdroży do AKS. Odśwież publiczne IP w przeglądarce po 2-3 minutach. 
*(W ramach testu bramki jakości, spróbuj zrobić w pythonie błąd np. usuń dwukropek – GitHub natychmiast zablokuje proces).*

**Ddatkowe punkty:**  Wyślij plik task7-.yml do oceny. Jeżeli nie udało Ci się wykonać ostaniego zadnia, wyślij kod i zrzuty erkanu wcześniejszych zadań aby otrzymać miejszą liczbę punktów za pomocą pliku PDF oraz folderu zip.

---

---

## 🧹 - Sprzątanie środowiska

Działający klaster AKS generuje koszty. Pozostawienie go włączonego wyczerpie Twoje środki studenckie.

**Wykonaj to na sam koniec zajęć:**
1. Otwórz potok `task5-terraform.yml` w VS Code.
2. Zmodyfikuj komendę w kroku "Budowa infrastruktury" z `terraform apply -auto-approve` na `terraform destroy -auto-approve`.
3. Zrób Commit, uruchom potok w GitHubie i upewnij się, że infrastruktura została skasowana. Możesz to potwierdzić w Azure Cloud Shell wpisując `az group list`.
4. Oraz sprwadzić w webie: https://portal.azure.com/#servicemenu/Microsoft_Azure_Resources/ResourceManager/resourcegroups