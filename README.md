<div align="center">

# ☁️ PFSwChO - Laboratorium 5
Zadanie *nieobowiązkowe* do wykonania w celu laboratorium. ☁️

</div>

### Krok 0: Utworzenie przestrzeni nazw

##### Polecenie:
```bash
kubectl create ns lab5
```

##### Zrzut ekranowy:
<div align="center">

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
```bash
kubectl apply -f lab5quota.yaml
```

##### Zrzut ekranowy:

<div align="center">

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
```bash
kubectl apply -f worker_resoursed.yaml
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

![2](https://github.com/Zeusek/PFSwChO/assets/33155636/1dcc0dbd-3080-45ce-acf5-3d37f99edfc4)

</div>

### Krok 3: Modifykacja plików z dokumentacji

Ciekawym efektem wykonanego poniżej polecenia jest fakt, że plik `.yaml` posiada dodatkowy wewnetrzny zapis w formacie `.json`.


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
    namespace: default
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
    namespace: default
  spec:
    ports:
    - port: 80
    selector:
      run: php-apache
kind: List
metadata: {}
```
##### Polecenie:
```bash
kubectl apply -f php-apache.yaml
```

Zadanie wspomina o przestrzeni nazw określonej jako `zad4` lecz człowiek to nie robot, pomylić się może. Zostało domyślnie przyjęte iż chodzi o `zad5` (w tym przypadku, student również to nie robot i został przyjęty zapis `lab` zamiast `zad`).

##### Zrzut ekranowy:

<div align="center">

<div align="right">
  
###### Pobranie pliku z dokumentacji

</div>

![image](https://github.com/Zeusek/PFSwChO/assets/33155636/c3a44444-ff36-4a97-9928-ead86793cca1)


<div align="right">
  
###### Modyfikacja pliku `php-apache.yaml`

</div>

![image](https://github.com/Zeusek/PFSwChO/assets/33155636/5c291c4d-f5ec-412e-b284-c6e8e8023b53)

</div>



### Krok 4: Utworzenie pliku `.yaml` służący do autoskalowania

Aby wykorzystać HorizontalPodAutoscaler (`HPA`) musimy uruchomić serwer metryk.

Polecenie:
```bash
minikube addons enable metrics-server
minikube addons list | grep -i metrics-server
```

```bash
kubectl autoscale deployment php-apache -n lab5 --cpu-percent=50 --max=5 --min=1 --dry-run=client -o yaml > php-apache_autoscale.yaml
```

Zrzut ekranowy:

<div align="center">

Uruchomienie serwera metryk
![image](https://github.com/Zeusek/PFSwChO/assets/33155636/04082e2d-bab2-4eb8-973b-91b549d32a91)


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
