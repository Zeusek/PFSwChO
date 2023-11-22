<div align="center">

# ☁️ PFSwChO - Laboratorium 5
Zadanie *obowiązkowe* do wykonania w celu laboratorium. ☁️

</div>

### Krok 0: Utworzenie przestrzeni nazw

##### Polecenie:
```bash
kubectl create ns lab5
```

##### Zrzut ekranowy:
<div align="center">

<div align="right">

  ###### Utworzenie przestrzeni nazw
  
</div>

![0](https://github.com/Zeusek/PFSwChO/assets/33155636/707ec43a-e040-4acb-b94d-b2c167da37b5)


</div>

### Krok 1: Utworzenie pliku `.yaml` dla quota na przestrzeń nazw

##### Wymagania:
- [x] Maksymalna liczba podów: `10`
- [x] Zasoby CPU: `2000m`
- [x] Zasoby RAM: `1,5Gi`

##### Polecenie:
```bash
kubectl create quota lab5quota --namespace=lab5 --hard=cpu=2000m,pods=10,memory=1.5Gi --dry-run=client -o yaml > lab5quota.yaml
```

##### Zrzut ekranowy:

<div align="center">

<div align="right">

  ###### Utworzenie pliku .yaml quota dla przestrzeni nazw
  
</div>

![1](https://github.com/Zeusek/PFSwChO/assets/33155636/abeeb289-5f93-4308-bdbd-91858c8c7153)

</div>


### Krok 2: Utworzenie pliku `.yaml` dla poda `worker` z ograniczeniami zasobów

##### Wymagania:
- [x] Maksymalne:    
  - Zasoby RAM: `200Mi`
  - Zasoby CPU: `200m`

- [x] Wymagane:
  - Zasoby RAM: `100Mi`
  - Zasoby CPU: `100m`

##### Polecenie utworzenia poda:
```bash
kubectl run worker --namespace=lab5 --image=nginx --dry-run=client -o yaml > worker.yaml
```

##### Polecenie dodające zasoby ograniczające poda:

Bazując na wcześniejszym pliku `worker.yaml`, utworzony jest kolejny plik z dodanymi limitami i wymaganiami.

```bash
kubectl set resources -f worker.yaml --requests=cpu=100m,memory=100Mi --limits=cpu=200m,memory=200Mi --local --dry-run=client -o yaml > worker_resoursed.yaml
```

##### Plik `worker_resoursed.yaml`:
```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: worker
  name: worker
  namespace: lab5
spec:
  containers:
  - image: nginx
    name: worker
    resources:
      limits:
        cpu: 200m
        memory: 200Mi
      requests:
        cpu: 100m
        memory: 100Mi
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

##### Zrzut ekranowy:

<div align="center">

<div align="right">

  ###### Utworzenie pliku .yaml dla poda `worker` z zasobami
  
</div>

![2](https://github.com/Zeusek/PFSwChO/assets/33155636/1dcc0dbd-3080-45ce-acf5-3d37f99edfc4)

</div>

### Krok 3: Modifykacja plików z dokumentacji

❄️ Ciekawym efektem wykonanego poniżej polecenia jest fakt, że plik `.yaml` posiada dodatkowy wewnetrzny zapis w formacie `.json`.


##### Polecenie:
```bash
kubectl apply -f https://k8s.io/examples/application/php-apache.yaml --namespace=lab5 --dry-run=client -o yaml > php-apache.yaml
```

##### Plik `php-apache.yaml`:
```yaml
apiVersion: v1
items:
- apiVersion: apps/v1
  kind: Deployment
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"apps/v1","kind":"Deployment","metadata":{"annotations":{},"name":"php-apache","namespace":"default"},"spec":{"selector":{"matchLabels":{"run":"php-apache"}},"template":{"metadata":{"labels":{"run":"php-apache"}},"spec":{"containers":[{"image":"registry.k8s.io/hpa-example","name":"php-apache","ports":[{"containerPort":80}],"resources":{"limits":{"cpu":"500m"},"requests":{"cpu":"200m"}}}]}}}}
    name: php-apache
    namespace: lab5
  spec:
    selector:
      matchLabels:
        run: php-apache
    template:
      metadata:
        labels:
          run: php-apache
      spec:
        containers:
        - image: registry.k8s.io/hpa-example
          name: php-apache
          ports:
          - containerPort: 80
          resources:
            limits:
              cpu: 250m
              memory: 250Mi
            requests:
              cpu: 150m
              memory: 150Mi
- apiVersion: v1
  kind: Service
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"labels":{"run":"php-apache"},"name":"php-apache","namespace":"default"},"spec":{"ports":[{"port":80}],"selector":{"run":"php-apache"}}}
    labels:
      run: php-apache
    name: php-apache
    namespace: lab5
  spec:
    ports:
    - port: 80
    selector:
      run: php-apache
kind: List
metadata: {}
```

❄️ Niestety, ale ustawienie zasobów za pomocą `kubectl set resources...` nie było możliwe, ponieważ polecenie ustawiało zasoby jedynie dla typu `Deployment`, a usuwało linie związane z typem `Service`. 

Zadanie wspomina o przestrzeni nazw określonej jako `zad4` lecz człowiek to nie robot, pomylić się może. Zostało domyślnie przyjęte iż chodzi o `zad5` (w tym przypadku, student również to nie robot i został przyjęty zapis `lab` zamiast `zad`).

##### Zrzuty ekranowe:

<div align="center">

<div align="right">
  
###### Pobranie pliku z dokumentacji

</div>

![3](https://github.com/Zeusek/PFSwChO/assets/33155636/c3a44444-ff36-4a97-9928-ead86793cca1)


<div align="right">
  
###### Modyfikacja pliku `php-apache.yaml`

</div>

![4](https://github.com/Zeusek/PFSwChO/assets/33155636/5c291c4d-f5ec-412e-b284-c6e8e8023b53)

</div>



### Krok 4: Utworzenie pliku `.yaml` służący do autoskalowania

Aby wykorzystać HorizontalPodAutoscaler (`HPA`) musimy uruchomić serwer metryk.

##### Polecenie:
```bash
minikube addons enable metrics-server
minikube addons list | grep -i metrics-server
```

##### Wymagania:
- [x] Średnie zużycie CPU: `50%`
- [x] Maksymalna ilość podów do skalowania: `7`
- [x] Minimalna ilość podów do skalowania: `1`


```bash
kubectl autoscale deployment php-apache --namespace=lab5 --cpu-percent=50 --max=7 --min=1 --dry-run=client -o yaml > php-apache_autoscale.yaml
```

##### Zrzuty ekranowe:

<div align="center">
<div align="right">
  
###### Uruchomienie serwera metryk

</div>

![5](https://github.com/Zeusek/PFSwChO/assets/33155636/04082e2d-bab2-4eb8-973b-91b549d32a91)

<div align="right">
  
###### Wygenerowanie pliku `php-apache_autoscale.yaml` z wymaganiami

</div>

![6](https://github.com/Zeusek/PFSwChO/assets/33155636/f03d4101-bf0f-49e1-96e3-cb0db91335d6)


</div>

> [!IMPORTANT]
> #### Uzasadnienie      
> Wstępnie ustalona `maksymalna ilość replik` została określona na `7`, natomiast po wykonaniu testu obciążającego serwis `php-apache` zmodyfikowanym skryptem umieszczonym w laboratorium 5 tj. 
> ```bash
> while sleep 0.001; do curl http://localhost:8080/; done
> ```
> hipotezy są dwie:
>  1. Zmodyfikowany skrypt funkcjonuje poprawnie i wystarczająca maksymalna ilość replik jest satysfakcjonująca w ilości `5`* (zrzut ekranowy przedstawia `42% / 50%` repliki  4).
>  2. Zmodyfikowany skrypt nie jest odzwierciedleniem faktycznego skryptu z laboratorium pod względem możliwego obciążenia i efekt pierwotnego skryptu jest widoczny w `laboratorium 5`, tj. obciążenie przy ilości `5` replik widnieje na poziomie `64% / 50%`. Sugeruje to, że optymalna ilość replik musi zostać określona w ilości `7`*.
> 
> #### ⚖️ Wzór 
> Dla hipotezy (wystarczającej) 1 :
> 
> $$ maxReplicas = \lceil{ cpuResources \over cpuDeploymentLimits } * targetCpuUtilizationPercentage\rceil $$
> 
> Przykład:
> 
> $$ maxReplicas =  \lceil{ 1800m \over 250m } * 0.5\rceil = \lceil { 7.2 } * 0.5\rceil  = \lceil{ 3.6 }\rceil = 4 $$
> 
> ---
> Dla hipotezy (bezpiecznej) 2:
> 
> $$ maxReplicas = \lfloor{ cpuResources \over cpuDeploymentLimits }\rfloor $$
>
> Przykład:
>
> $$ maxReplicas = \lfloor{ 1800m \over 250m }\rfloor = \lfloor{ 7.2 }\rfloor = 7 $$
>
> **Podsumowanie**
> 
> Faktyczną maksymalną ilość replik można wyliczać z wymyślonych wzorów, jednakże najlepszą "namacalną" metodą aby dobrać odpowiednią ilość potrzebnych podów bez przekraczania limitu jest sprawdzenie możliwości obciążenia deploymentu skryptem lub też innym sztucznie wygenerowanym ruchem. W przypadku testów obciążenie było wystarczające na 5 replik, przy założeniu, że jedna została dodana w celach "bezpieczeństwa".
> 
> \* - Przy bezpiecznym założeniu +1 ilości repliki.
> 
> \** - Najlepszym sposobem by określić maksymalną ilość replik jest sprawdzenie przepływu zapytań na serwer.

### Krok 5: Skrypt tworzący obiekty z `.yaml`

W celu zautomatyzowania poleceń na plikach `.yaml`, został stworzony skrypt bashowy. Aby móc za pomocą jednego polecenia załadować wszystkie pliki należy uprzednio włączyć minikube:
```bash
minikube start
```
Kolejnym krokiem będzie wywołanie skryptu:
```bash
./install.sh
```

> Skrypt operuje na przestrzeni nazw `lab5`

##### Skrypt `install.sh`
```bash#!/bin/bash
echo -e "\n\t ☁️ Instalacja zainicjowana. ☁️\n"

date

echo -e "\n\t 🔧 Tworzenie przestrzeni nazw\n"
minikube kubectl -- create ns lab5

sleep 2

echo -e "\n\t 🔧 Aplikowanie plików .yaml\n"
minikube kubectl -- apply -f lab5quota.yaml

sleep 2

minikube kubectl -- apply -f worker_resoursed.yaml

sleep 2

echo -e "\n\t 🔧 Sprawdzenie serwera metryk\n"
if [[ $(minikube addons list | grep -i metrics-server | cut -d "|" -f 4 | cut -d " " -f 2) = "enabled" ]]  
then
        echo -e "\t☁️ Serwer metryk jest już uruchomiony!\n"
else
        echo -e "\t😶‍🌫️ Serwer metryk jest wyłączony, już go uruchamiam.\n"
        sleep 1
        minikube addons enable metrics-server
fi

sleep 2

echo -e "\n\t 🔧 HPA time!\n"
minikube kubectl -- create -f php-apache_autoscale.yaml

sleep 1

minikube kubectl -- apply -f php-apache.yaml

sleep 1

echo -e "\n\t ☁️ Instalacja zakończona. ☁️\n\n"

minikube kubectl -- get quota -n lab5
minikube kubectl -- describe hpa php-apache -n lab5

echo -e "\n\n Chwilę należy odczekać po uruchomieniu."
```
##### Zrzut ekranowy:

<div align="center">
<div align="right">

###### Wywołanie skryptu automatyzującego
  
</div>

![7](https://github.com/Zeusek/PFSwChO/assets/33155636/b933dc1b-f84e-414f-a50c-66d8c6d5631a)

</div>


### Krok 6: Test obciążający

> [!WARNING]
> Polecenie to nie zostało wykorzystane w trakcie testu obciążenia.
> ```bash
> kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"
> ```

> [!NOTE]
> Zbiór poleceń, które zostały zastosowane to:
> 
> Przekazanie portu na `8080`
> ```bash
> kubectl port-forward deploy/php-apache -n lab5 8080:80
> ```
> 
> Wysłanie zapytania pobierającego zawartość strony
> ```bash
> while sleep 0.001; do curl http://localhost:8080/; done
> ```
>
> Sprawdzenie szczegółów HPA dla `php-apache`
> ```bash
> kubectl describe hpa php-apache -n lab5
> ```

##### Zrzuty ekranowe:

<div align="center">
<div align="right">
 
</div>


<div align="right">

###### Przekierowanie portu na `8080`

</div>

  ![8](https://github.com/Zeusek/PFSwChO/assets/33155636/afa7196c-6351-40ad-bb29-0fd0720cc004)

<div align="right">

###### Wykonanie testu obciążajcego

</div>

![9](https://github.com/Zeusek/PFSwChO/assets/33155636/6574cef6-4a2d-4e63-ae2c-fc70cedece42)

<div align="right">

###### Wykonanie polecenia `describe` w celu sprawdzenia szczegółów HPA w ``przed` działaniem skryptu obciążającego

</div>

![11](https://github.com/Zeusek/PFSwChO/assets/33155636/110e0154-5bcc-4cc0-89c4-a31f276a2c67)


<div align="right">

###### Wykonanie polecenia `describe` w celu sprawdzenia szczegółów HPA ``w trakcie`` działania skryptu obciążającego

</div>

![12](https://github.com/Zeusek/PFSwChO/assets/33155636/416ea96b-ff63-4c7b-b6c1-40a1c7d07544)

<div align="right">

###### Wykonanie polecenia `describe` w celu sprawdzenia szczegółów HPA ``po`` wyłączeniu skryptu obciążającego

</div>

![13](https://github.com/Zeusek/PFSwChO/assets/33155636/a9bf15cf-d1e4-4a90-ae28-5738c56809de)

</div>

---

<div align="right"

  ☁️ ☁️ ☁️
  
  </div>
