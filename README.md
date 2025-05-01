<div align="center">
    <h1>CTFd-packaged</h1>
    <a href=""><img src="https://img.shields.io/github/license/ctfer-io/ctfd-packaged?style=for-the-badge" alt="License"></a>
    <a href="https://securityscorecards.dev/viewer/?uri=github.com/ctfer-io/ctfd-packaged"><img src="https://img.shields.io/ossf-scorecard/github.com/ctfer-io/ctfd-packaged?label=openssf%20scorecard&style=for-the-badge" alt="OpenSSF Scoreboard"></a>
</div>

This repository is an internal tool to generate pre-packaged versions of CTFd.

Actually, it is used to publish the Docker image [`ctferio/ctfd`](https://hub.docker.com/r/ctferio/ctfd).
This image integrate our work for direct reuse, plus fits our security policies regarding traceability and auditability regarding Software Supply Chain.

It contains:
- [CTFd](https://github.com/ctfd/ctfd)
- [CTFd-Chall-Manager](http://github.com/ctfer-io/ctfd-chall-manager)

## Security

### Signature and Attestations

For deployment purposes (and especially in the deployment case of Kubernetes), you may want to ensure the integrity of what you run.

The Docker image is SLSA 3 and can be verified using [slsa-verifier](https://github.com/slsa-framework/slsa-verifier) using the following.

```bash
slsa-verifier slsa-verifier verify-image "ctferio/ctfd:<tag>@sha256:<digest>" \
    --source-uri "github.com/ctfer-io/ctfd" \
    --source-tag "<tag>"
```

Alternatives exist, like [Kyverno](https://kyverno.io/) for a Kubernetes-based deployment.

### SBOMs

A SBOM is generated for the Docker image in its manifest, and can be inspected using the following.

```bash
docker buildx imagetools inspect "ctferio/ctfd:<tag>" \
    --format "{{ json .SBOM.SPDX }}"
```
