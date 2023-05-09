::: mermaid
gantt
    title Moodle Project Planner
    dateFormat  YYYY-MM-DD
    excludes    weekends

    section Performance Enhancements
    Build Nginx Deployment        :done, nginx, 2023-03-01 , 40d
    Deploy to OpenShift           :active, after nginx, 15d
    Integrate with ArgoCD         :active, 2023-05-03 , 14d
    Integrate with GitHub Actions :crit, 2023-06-01 , 15d

    section GDX Snowplow Stats
    Training                 : 2023-05-10 , 2d
    Setup Account            :account, 2023-05-10, 1d
    Deploy Scripts to Moodle :deploy1, after account , 1d
    Monitoring and Reporting :after deploy1, 50d

    section ArgoCD
    Acquire Namespace                      :done, 2023-04-25 , 1d
    Requested the separate repository      :done, setup1, 2023-04-25 , 1d
    Discussions / Training                 :after setup1, 2023-05-03 , 7d
    Deploy on temporary namespace (ee6ac2) : 15d
    Configure / Validate                   : 15d
    Test deployments and server config :crit , 7d
    Test GDX Snowplow Stats            : 2d
    Load test                          : 7d
    Final Config / Optimizations       :crit, 7d

    section Completion Bridge
    Deploy and Validate Dataflow updates : 2023-05-15 , 7d

    section Vanity URL
    URL Approvel by GDX                     :done, 2023-04-20 , 5d
    Request domain (learning.gww.gov.bc.ca) :active, 2023-04-25 , 14d
    Request SSL Certificate (iStore)        :active, 2023-05-01 , 14d
    Deploy Route and SSL Updates            :crit, 2023-05-17 , 7d
:::