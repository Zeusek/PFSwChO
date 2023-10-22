<div align="center">

# ☁️ PFSwChO - Laboratorium 3
Zadanie *nieobowiązkowe* do wykonania w celu laboratorium. ☁️

</div>

## Krok 1: Utworzenie przestrzeni nazw

```bash
kubectl create namespace lab3
```

Zrzut ekranowy:
![0](https://github.com/Zeusek/PFSwChO/assets/33155636/b737aff7-1f6d-4202-a3ec-88adbcf5f7bd)

## Krok 2: Utworzenie pliku YAML dla pod-a w wersji podstawowej

Polecenie:
```bash
kubectl run sidecar-pod --namespace=lab3 --dry-run=client -o yaml --image=busybox -- /bin/sh -c "while true; do date >> /var/log/date.log; sleep 5; done" > sidecar-pod.yaml
```

Zrzut ekranowy:
![1](https://github.com/Zeusek/PFSwChO/assets/33155636/7fd60ac9-3ac0-4999-a553-eb46f43e2972)

## Krok 3: Modyfikacja pliku YAML dla pod-a w wersji finalnej

Plik yaml:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-pod
  namespace: lab3
spec:
  containers:
	- name: busybox-container
  	image: busybox
  	command:
    	- "/bin/sh"
    	- "-c"
    	- "while true; do date >> /var/log/date.log; sleep 5; done"
  	volumeMounts:
    	- name: shared-volume
      	mountPath: /var/log
	- name: nginx-container
  	image: nginx
  	ports:
    	- containerPort: 80
  	volumeMounts:
    	- name: shared-volume
      	mountPath: /usr/share/nginx/html
  volumes:
	- name: shared-volume
  	hostPath:
    	path: /var/log
  restartPolicy: Never
```

Zrzut ekranowy:
![2](https://github.com/Zeusek/PFSwChO/assets/33155636/aeb12668-e316-4f6a-882e-f90799e78e22)


### Krok 4: Utworzenie pod-a

Polecenie:
```bash
kubectl create -f sidecar-pod.yaml
```

Zrzut ekranowy:
![3](https://github.com/Zeusek/PFSwChO/assets/33155636/15fe6d61-9187-42fa-92f6-900fa2a5bc9d)

### Krok 5: Ustawienie port-forwarding

Polecenie:
```bash
kubectl port-forward -n lab3 sidecar-pod 8080:80
```

Zrzut ekranowy:
![4](https://github.com/Zeusek/PFSwChO/assets/33155636/799cee34-7975-40bf-b014-2d8515d78ea3)

### Krok 6: Wykonanie żądania za pomocą programu curl

Polecenie:
```bash
curl http://localhost:8080/date.log
```

Zrzut ekranowy:
![5](https://github.com/Zeusek/PFSwChO/assets/33155636/1db3f8cf-027f-48d1-bd0b-7815dccf6fa1)

#### Weryfikacja

Zrzut ekranowy:
![6](https://github.com/Zeusek/PFSwChO/assets/33155636/dabd8798-e8e9-462c-9c6d-83d28dcfcf06)

---
<div align="right"

  ☁️ ☁️ ☁️
  
  </div>
