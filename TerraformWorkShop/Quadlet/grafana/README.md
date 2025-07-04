after install grafana, consider install plugin([Grafana Logs Drilldown](https://grafana.com/grafana/plugins/grafana-lokiexplore-app/?tab=overview))  offline:
1. Download plugin zip file [Grafana Logs Drilldown\Installation](https://grafana.com/grafana/plugins/grafana-lokiexplore-app/?tab=installation) to local computer, then unzip it to `C:\Users\Public\Downloads\grafana\`
2. copy it to grafana pvc dir:
```powershell
scp -r "C:\Users\Public\Downloads\grafana\grafana-lokiexplore-app" Day1-FCOS:/var/home/podmgr/.local/share/containers/storage/volumes/grafana-pvc/_data/plugins/
```
3. restart grafana systemd service
```shell
systemctl --user restart grafana.service
```