# Changelog

All notable changes to this project will be documented in this file.

## Release 1.5.1

**Features**

- #47 : add env vars
- #46 : change query_frontend_log_queries_longer_than to String

## Release 1.5.0

**Features**

- #37 : Remove unsed parameter block_sync_concurrency in Thanos Compactor
- #38 : fix receiver tsdb.path var name and add labels flag
- #40 : increase puppet-archive dependency to < 7.0.0

## Release 1.4.0

**Features**

- Introducing a prefix parameter for the storage config , defaults to empty

## Release 1.3.0

**Features**

- Support Thanos version 0.26.0

**Bug Fixes**

- Fix : systemctl daemon-reload after service file changed

## Release 1.2.0

**Features**

- Support Thanos version 0.16.0

## Release 1.1.0

**Features**

- Support Thanos version 0.15.0

## Release 1.0.2

**Bug Fixes**

- Fix building package (remove useless folders)

## Release 1.0.1

**Bug Fixes**

- Fix a bug into Sidecar default parameters
- Code optimization

## Release 1.0.0

- First major release

## Release 0.4.2

- Acceptance tests.
- Automatic deploy via the CI.

## Release 0.4.1

**Bug Fixes**

- Fix Bucket Web service.

## Release 0.4.0

**Features**

- Add Bucket Web service.
- Add Index Cache.
- Add new Query, Rule, Sidecar and Store parameters

## Release 0.3.0

**Features**

- Add extra parameters to do compatible with future versions of Thanos binary.

## Release 0.2.1

**Bug Fixes**

- User and group was not set in Service file.
- Service is notified when Service file changed.
- Set the default version to 0.10.1

## Release 0.2.0

**Features**

- Storage and Tracing configuration  
- Optimization and testings
    
**Bug Fixes**

- Service file creation with removing of useless new line return.  

## Release 0.1.4

**Bug Fixes**

- Service file correction with useless new line returns  

## Release 0.1.3

**Features**

- Unit tests  
    
**Bug Fixes**

- Boolean parameters in service resource creation.  

## Release 0.1.2

**Features**

- Documentation, README and REFERENCE

## Release 0.1.1

- Test release

## Release 0.1.0

**Features**

- Installation and component's Service creation
