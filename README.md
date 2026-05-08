# apex-examples

Reference Apex classes that demonstrate how to set up test data for the [Kugamon Quote-to-Cash] (https://appexchange.salesforce.com/) managed package (`kugo2p` namespace).

The first example, `KugamonTests`, originated as a public gist in 2017 and is now maintained here so partners and customers can clone it, deploy it to a sandbox or scratch org, and use it as a starting point for their own Apex test classes that interact with Kugamon objects.

## What this example covers

`KugamonTests` builds a complete Kugamon object graph in a single test data setup, including:

- Kugamon Settings and the Standard / Custom Pricebooks
- Products, Additional Product Definitions (APDs), and pricing tiers
- Opportunities and Opportunity Line Items
- Sales Quotes with Product, Service, Optional, and Accessory (ACC) lines
- Sales Orders with Product, Service, and Accessory lines
- Invoices, Invoice lines, Invoice ACCs, and the Order-Invoice Relationship

It is structured so individual `@isTest` methods can call `DataSetup()` and then assert against specific subgraphs.

## Prerequisites

- A Salesforce org (sandbox, Developer Edition, or scratch org) with the **Kugamon Quote-to-Cash** managed package installed
- [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli) (`sf`) v2 or later
- API version 60.0 or higher in the target org

## Quick start

```bash
# 1. Clone the repo
git clone https://github.com/kugamon/apex-examples.git
cd apex-examples

# 2. Authorize your target org
sf org login web --alias kugamon-sandbox

# 3. Deploy the example class
sf project deploy start --target-org kugamon-sandbox

# 4. Run the test
sf apex run test --class-names KugamonTests --target-org kugamon-sandbox --result-format human --code-coverage
```

## Repository layout

```
apex-examples/
├── README.md
├── LICENSE                 (MIT)
├── .gitignore
├── sfdx-project.json
└── force-app/
    └── main/
        └── default/
            └── classes/
                ├── KugamonTests.cls
                └── KugamonTests.cls-meta.xml
```

## Disclaimer

This is reference code provided as-is. It is **not** part of the Kugamon managed package and is **not** supported by Kugamon Support. The schema it depends on (`kugo2p__*` objects and fields) may evolve between package releases — if a deployment fails after a Kugamon upgrade, the class may need to be updated to match the new schema.

## Links

- [Kugamon on the AppExchange](https://appexchange.salesforce.com/)
- [Kugamon website](https://www.kugamon.com)
- Original gist (now redirected here): https://gist.github.com/kuldiph/0f458ff628e1744adf5cce666b0985bc

## License

Released under the [MIT License](LICENSE).
