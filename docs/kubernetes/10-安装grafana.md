# 安装grafana

```yaml
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: grafana-data
  namespace: grafana
spec:
  storageClassName: infra
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi


---
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: grafana
  labels:
    app: grafana
spec:
  type: ClusterIP
  ports:
    - name: http
      port: 3000
      targetPort: 3000
  selector:
    app: grafana


---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: grafana
  namespace: grafana
  labels:
    app: grafana
spec:
  serviceName: grafana
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
        - name: grafana
          image: harbor.idc.roywong.top/docker.io/grafana/grafana:10.4.0
          ports:
            - name: http
              containerPort: 3000
          resources:
            requests:
              cpu: 100m
              memory: 512Mi
            limits:
              cpu: 2000m
              memory: 4906Mi
          volumeMounts:
            - name: grafana-data
              mountPath: /var/lib/grafana
      volumes:
        - name: grafana-data
          persistentVolumeClaim:
            claimName: grafana-data


---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana
  namespace: grafana
spec:
  ingressClassName: nginx
  rules:
    - host: grafana.idc-ingress-nginx.roywong.top
      http:
        paths:
        - path: /
          pathType: ImplementationSpecific
          backend:
            service:
              name: grafana
              port:
                number: 3000
  tls:
    - hosts:
        - grafana.idc-ingress-nginx.roywong.top
      secretName: tls-wildcard-idc-ingress-nginx-roywong-top
```