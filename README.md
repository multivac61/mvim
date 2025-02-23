`mvim` is my own bespoke neovim config based on
[LazyVim](https://www.lazyvim.org) and `nix`.

Try it yourself...

```console
nix run github:multivac61/mvim
```

## Bootstrapping your own

You can fork this repository and change the `lua` in the root directory.

`./.github/workflows/update-flake-lock.yml` and
`./.github/workflows/update-lazy-plugins.yaml` use the
[create-github-app-token](https://github.com/actions/create-github-app-token?tab=readme-ov-file#usage)
action. In order to use it in your project you need to
[register a new GitHub app](https://docs.github.com/en/apps/creating-github-apps/registering-a-github-app/registering-a-github-app).
In order to use this action, you need to:

1. [Register new GitHub App](https://docs.github.com/en/apps/creating-github-apps/registering-a-github-app/registering-a-github-app#registering-a-github-app).
   When creating the app you need to enable read and write access for "Contents"
   and "Pull Requests" permissions.
2. Next you must
   [install the app to make it available to your repo](https://docs.github.com/en/apps/using-github-apps/installing-your-own-github-app#installing-your-own-github-app)
   .
3. [Store the App's ID in your repository environment variables](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/store-information-in-variables#creating-configuration-variables-for-a-repository)
   as `CI_APP_ID`.
4. [Store the App's private key in your repository secrets](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/store-information-in-variables#creating-configuration-variables-for-a-repository)
   as `CI_PRIVATE_KEY`.
5. Create a new `auto-merge`
   [label in the GitHub UI](https://docs.github.com/en/issues/using-labels-and-milestones-to-track-work/managing-labels#creating-a-label).

Then you can upload the code to your own GitHub repo and

> [!NOTE]
> Lots of the `nix` and CICD code is adopted from the venerable
> [Mic92](https://github.com/Mic92/dotfiles)
