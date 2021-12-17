# iterarte over all folder and launch mvn clean install and dependency:tree | grep log4j to log log4j depenedencies on all projects

rootAbsolutPath=$1

for d in ${rootAbsolutPath}*/; do
  echo Projects in progress : "$d"
  pom_path=./
  if [ -d "${d}src" ]; then
    pom_path="${d}src"
  else
    pom_path="${d}"
  fi

  echo move to "$pom_path"
  cd "$pom_path"

  echo mvn clean install in "$pom_path"
  mvn clean install -DskipTests >/dev/null

  echo launch mvn dependency:tree | grep log4j-core
  mvn dependency:tree | grep log4j-core

  if [ -d "${d}src" ]; then
    cd ../../
  else
    cd ../
  fi
done
