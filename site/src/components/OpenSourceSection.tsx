import { GITHUB_URL } from "../constants";

export function OpenSourceSection() {
  return (
    <p className="openSourceLine container">
      MIT open source —{" "}
      <a href={GITHUB_URL} target="_blank" rel="noreferrer">
        fork it on GitHub
      </a>{" "}
      if you want your own flavor.
    </p>
  );
}
