<div align="center">

# ☁️ PFSwChO - Laboratorium 4
Zadanie *nieobowiązkowe* do wykonania w celu laboratorium. ☁️

</div>

### Krok 1: Utworzenie przestrzeni nazw

##### Polecenie:
```bash
kubectl create ns lab4
```

##### Zrzut ekranowy:
<div align="center">

![0](https://github.com/Zeusek/PFSwChO/assets/33155636/78064ca1-a7bc-4637-918e-aaaee6d2f9ff)

</div>

### Krok 2: Utworzenie quota(y?) z ograniczeniami na przestrzeń nazw

##### Polecenie:
```bash
kubectl create quota lab4quota --hard=cpu=1,memory=1G,pods=5 --namespace=lab4
```

##### Zrzut ekranowy:

<div align="center">

![1](https://github.com/Zeusek/PFSwChO/assets/33155636/e1fd5ceb-12b8-42a5-81d2-a17e984b8e20)
![2](https://github.com/Zeusek/PFSwChO/assets/33155636/02a57d6c-1e34-4034-bc6c-711a969ffaa1)

</div>


### Krok 3: Utworzenie deploymentu

Utworzenie deploymentu dla przestrzeni nazw ograniczonego quotą i trzema replikami.

Polecenie przekazane "na sucho" do pliku ``.yaml``, by móc określić zasoby w następnym kroku.

##### Polecenie:
```bash
kubectl create deploy restrictednginx --image=nginx -n lab4 --replicas=3 --dry-run=client -o yaml > rngix.yaml
```

##### Plik .yaml:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: restrictednginx
  name: restrictednginx
  namespace: lab4
spec:
  replicas: 3
  selector:
    matchLabels:
      app: restrictednginx
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: restrictednginx
    spec:
      containers:
      - image: nginx
        name: nginx
        resources: {}
status: {}
```

##### Zrzut ekranowy:

<div align="center">

![3](https://github.com/Zeusek/PFSwChO/assets/33155636/c794425b-d53b-4bbd-8f93-401a8d088e09)

</div>

### Krok 4: Ustawienie minimalnych i maksymalnych zasobów

Dzięki argumentom ``--local --dry-run=client -o yaml >`` możliwe jest przekazanie ustawionych wymagań z wcześniej utworzonego pliku.

Niestety w momencie, gdy próbujemy nadpisac wcześniej utworzony plik ``rngix.yaml`` używając ``>`` to plik zostaje wyczyszczony, jedynym(?) lekarstwem tej przypadłości jest przypisanie zmodyfikowanej konfiguracji do nowego pliku ``.yaml``.

##### Polecenie:
```bash
kubectl set resources -f rngix.yaml --requests=cpu=125m,memory=64Mi --limits=cpu=250m,memory=256Mi --local --dry-run=client -o yaml > rngix_resoursed.yaml
```

##### Plik .yaml:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: restrictednginx
  name: restrictednginx
  namespace: lab4
spec:
  replicas: 3
  selector:
    matchLabels:
      app: restrictednginx
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: restrictednginx
    spec:
      containers:
      - image: nginx
        name: nginx
        resources:
          limits:
            cpu: 250m
            memory: 256Mi
          requests:
            cpu: 125m
            memory: 64Mi
status: {}
```


##### Zrzut ekranowy:

<div align="center">

![4](https://github.com/Zeusek/PFSwChO/assets/33155636/87fd2ad6-c4c4-485f-bd22-f18ca5b71c7a)

</div>


### Krok 5: Uruchomienie deploymentu z wymaganiami

Polecenie:
```bash
kubectl apply -f rngix_resoursed.yaml
```

Zrzut ekranowy:

<div align="center">

![5](https://github.com/Zeusek/PFSwChO/assets/33155636/cfeb350f-6f27-4e1d-a548-77bc2a2937f6)

</div>

### Krok 6: Sprawdzenie obciążenia quoty

Polecenie:
```bash
kubectl get quota -n lab4
```

Zrzut ekranowy:

<div align="center">

![6](https://github.com/Zeusek/PFSwChO/assets/33155636/02b8b7f1-632d-4e5e-8fff-6068fb4746af)

</div>

---
<div align="right"

  ☁️ ☁️ ☁️
  
  </div>
