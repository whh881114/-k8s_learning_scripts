local vars = import 'vars.libsonnet';

{
  apiVersion: "v1",
  kind: "Namespace",
  metadata: {
    name: vars['namespace'],
  },
}